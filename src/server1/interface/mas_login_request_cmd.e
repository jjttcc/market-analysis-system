indexing
	description: "A command that responds to a GUI client log-in request"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class LOGIN_REQUEST_CMD inherit

	REQUEST_COMMAND

	GLOBAL_SERVER
		export
			{NONE} all
		undefine
			print
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		undefine
			print
		end

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
			-- Extract any settings from `msg', create a SESSION and add
			-- it to `sessions', apply the settings from `msg', and send
			-- a unique session ID to the requesting client.
			-- If a protocol error is encountered in `msg', an error
			-- status and an error message is sent to the client instead
			-- of a session ID.
		local
			session_id, i, j: INTEGER
			error_occurred, finished: BOOLEAN
			setting_type, error_msg: STRING
			sutil: STRING_UTILITIES
			tokens: LIST [STRING]
		do
			session_id := new_key
			create sutil.make (msg)
			create session.make
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
			if error_occurred then
				report_error (Error, <<error_msg>>)
				-- Don't add the new session.
			else
				send_ok
				print (session_id)
				print (eom)
				sessions.extend (session, session_id)
				-- Clearing the cache when a new login occurs ensures that
				-- a new client will receive up-to-date data.
				market_list_handler.clear_caches
			end
		ensure then
			one_more_session: sessions.count = old sessions.count + 1
			new_session: session /= Void and sessions.has_item (session)
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
			date_maker: DATE_TIME_SERVICES
			time_period: STRING
			date: DATE
		do
			create date_maker
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
					if settings.item.is_equal ("0") then
						create date.make (0, 0, 0)
					elseif settings.item.is_equal ("now") then
						create date.make_now
						-- Set date to 2 years in the future.
						date.set_year (date.year + 2)
					else
						date := date_maker.date_from_string (
									settings.item, Date_field_separator)
					end
					if date = Void then
						create Result.make (0)
						Result.append ("Invalid date for date %
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

end -- class LOGIN_REQUEST_CMD
