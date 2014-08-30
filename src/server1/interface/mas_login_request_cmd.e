note
	description: "A command that responds to a client log-in request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MAS_LOGIN_REQUEST_CMD

inherit

	LOGIN_REQUEST_CMD
		rename
			make as lrc_make_unused
		export
			{NONE} lrc_make_unused, initialize
		redefine
			session, put_session_state, pre_process_session,
			post_process_session
		end

	TRADABLE_REQUEST_COMMAND
		rename
			make as trc_make
		export
			{NONE} trc_make
		redefine
			session
		select
			rcmake
		end

inherit {NONE}

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		end

	GLOBAL_APPLICATION
		export
			{NONE} all
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

	DATE_PARSING_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (dispenser: TRADABLE_DISPENSER; auto_update: BOOLEAN)
		require
			dispenser_exists: dispenser /= Void
		do
			trc_make (dispenser)
			auto_update_on := auto_update
		ensure
			tradables_set: tradables = dispenser and tradables /= Void
			auto_update_set: auto_update_on = auto_update
		end

feature -- Access

	session: MAS_SESSION

feature -- Status report

	auto_update_on: BOOLEAN
			-- Is the feature for automatically updating the tradable
			-- source data on?

feature {NONE} -- Hook routine implementations

	create_session
		do
			create session.make
		end

	process (message: STRING)
		local
			setting_type: STRING
			tokens: LIST [STRING]
		do
			sutil.set_target (message)
			tokens := sutil.tokens (message_component_separator)
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
					error_occurred := True
					last_error := "Missing value for setting: "
					last_error.append (setting_type)
				else
					last_error := change_setting (setting_type, tokens)
					if last_error = Void then
						tokens.forth
					else
						error_occurred := True
					end
				end
			end
		end

	put_session_state
			-- Send the "session state" information (formatted according
			-- to the client/server communication protocol) to the client.
		do
			if not command_line_options.opening_price then
				put (message_component_separator)
				put (no_open_session_state)
			end
		end

	pre_process_session
		do
			if not command_line_options.intraday_caching then
				session.turn_caching_off
			end
		end

	post_process_session
		do
			if not auto_update_on then
				-- Clearing the cache when a new login occurs ensures that
				-- a new client will receive up-to-date data.
				tradables.clear_caches
			end
		end

feature {NONE} -- Implementation

	change_setting (type: STRING; settings: LIST [STRING]): STRING
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
						if settings.item.is_equal (Now) then
							-- Set "now" date to 100 years in the future to
							-- imitate an "eternal now".
							date := future_date
						end
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

end
