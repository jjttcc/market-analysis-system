indexing
	description: "A command that responds to a GUI client log-in request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class LOGIN_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND

	GLOBAL_SERVER
		export
			{NONE} all
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

	GUI_PROTOCOL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Status report

	error_occurred: BOOLEAN
			-- Did an error occur the last time `execute' was called?

feature -- Basic operations

	do_execute (msg: STRING) is
			-- Extract any settings from `msg', create a MAS_SESSION and add
			-- it to `sessions', apply the settings from `msg', and send
			-- a unique session ID to the requesting client.
			-- If a protocol error is encountered in `msg', an error
			-- status and an error message is sent to the client instead
			-- of a session ID.
		local
			session_id: INTEGER
			setting_type, error_msg: STRING
			tokens: LIST [STRING]
		do
			error_occurred := false
			session_id := new_key
			sutil.set_target (msg)
			create session.make
			if not command_line_options.intraday_caching then
				session.turn_caching_off
			end
			if not msg.is_empty then
				tokens := sutil.tokens (Input_field_separator)
				from
					tokens.start
				until
					tokens.exhausted or error_occurred
				loop
					-- Settings follow the pattern "setting_type%Tvalues", 
					-- where 'values' represents one or more fields and fields
					-- are separated by a tab character; extract the
					-- setting type (name) first and then 'values'.
					setting_type := tokens.item
					tokens.forth
					if tokens.exhausted then
						error_occurred := true
						error_msg := "Missing value for setting: "
						error_msg.append (setting_type)
					else
						error_msg := change_setting (setting_type, tokens)
						if error_msg = Void then
							tokens.forth
						else
							error_occurred := true
						end
					end
				end
			end
			if error_occurred then
				report_error (Error, <<error_msg>>)
				-- Don't add the new session.
			else
				put_ok
				put (session_id.out)
				put_session_state
				put (eom)
				sessions.extend (session, session_id)
				-- Clearing the cache when a new login occurs ensures that
				-- a new client will receive up-to-date data.
				tradables.clear_caches
			end
		ensure then
			one_more_session: not error_occurred implies
				sessions.count = old sessions.count + 1
			new_session: not error_occurred implies
				session /= Void and sessions.has_item (session)
		end

feature {NONE} -- Implementation

	new_key: INTEGER is
			-- A new key not currently used in `sessions'
		local
			keys: ARRAY [INTEGER]
			i: INTEGER
		do
			keys := sessions.current_keys
			if keys.count = 0 then
				Result := 1
			else
				-- Set Result to one greater than the highest key value.
				from
					i := 1
				until
					i > keys.count
				loop
					if keys @ i > Result then
						Result := keys @ i
					end
					i := i + 1
				end
				Result := Result + 1
			end
		ensure
			new_key: not sessions.has (Result)
		end

	change_setting (type: STRING; settings: LIST [STRING]): STRING is
			-- Extract the current setting value from `settings' and
			-- apply it to `sessions @ session_id'.  `settings.item' will
			-- reference the last element read.
			-- If an error in the format or protocol of `type' or `settings'
			-- is encountered, Result will be non-void and contain an
			-- appropriate error message and no other action will be taken.
			-- Otherwise, Result will be void.
		require
			not_void: type /= Void and settings /= Void
			session_not_void: session /= Void
		local
			time_period: STRING
			date: DATE
		do
			if type.is_equal (Start_date) or type.is_equal (End_date) then
				time_period := settings.item
				settings.forth
				if settings.exhausted then
					create Result.make (0)
					Result.append ("Invalid format for date setting of type ")
					Result.append (type)
					Result.append (" - missing date component")
				elseif not period_types.has (time_period) then
					create Result.make (0)
					Result.append ("Invalid time period type for date %
						%setting of type ")
					Result.append (type)
					Result.append (": ")
					Result.append (time_period)
				else
					date := date_from_string (settings.item)
					if date = Void then
						create Result.make (0)
						Result.append ("Invalid date specification for date %
							%setting of type ")
						Result.append (type)
						Result.append (": ")
						Result.append (settings.item)
					elseif type.is_equal (Start_date) then
						session.start_dates.force (date, time_period)
					else
						session.end_dates.force (date, time_period)
					end
				end
			else
				create Result.make (0)
				Result.append ("Invalid type for setting: ")
				Result.append (type)
			end
		end

	sutil: expanded STRING_UTILITIES

feature {NONE} -- Implementation - session state

	put_session_state is
			-- Send the "session state" information (formatted according
			-- to the client/server communication protocol) to the client.
		do
			if not command_line_options.opening_price then
				put (Output_field_separator)
				put (No_open_session_state)
			end
		end

end -- class LOGIN_REQUEST_CMD
