indexing
	description: "Abstraction for an event registrant that simply logs %
				%events to a file"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EVENT_LOG_FILE inherit

	MARKET_EVENT_REGISTRANT
		rename
			make as er_make
		export {NONE}
			er_make
		end

	GLOBAL_APPLICATION
		rename
			event_types as global_event_types
		export {NONE}
			all
		end

	EXCEPTIONS
		export {NONE}
			all
		end

creation

	make

feature {NONE} -- Initialization

	make (fname, event_history_file_name, field_sep, record_sep: STRING) is
			-- Create the file with `fname' as the file `name' and
			-- `hfile_name' set to `event_history_file_name'
			-- Open this file, with `fname', for appending in the application
			-- environment directory, if set.
		require
			fn_not_void_and_not_empty: fname /= Void and not fname.is_empty
			seps_not_void: field_sep /= Void and record_sep /= Void
		local
			env: APP_ENVIRONMENT
		do
			create env
			hfile_name := event_history_file_name
			field_separator := field_sep
			record_separator := record_sep
			er_make
			-- Object comparison is required because of the persistence
			-- mechanism - on retrieval from storage a member of `event_types'
			-- may be a different instance than the respective member of
			-- `global_event_types'.  (Originally they will be the same
			-- instance.)
			event_types.compare_objects
			create logfile.make (env.file_name_with_app_directory (fname,
				False))
			if not logfile.exists then
				-- Create the log file.
				logfile.open_write
				logfile.close
			end
		ensure
			names_set: name.is_equal (fname) and
				hfile_name.is_equal (event_history_file_name)
			separators_set: field_separator = field_sep and
				record_separator = record_sep
			logfile.exists
		end

feature -- Access

	name: STRING is
		do
			Result := logfile.name
		end

	type_description: STRING is
		once
			Result := "Log file"
		end
feature -- Basic operations

	perform_notify is
		local
			e: MARKET_EVENT
		do
			logfile.open_append
			from
				event_cache.start
			until
				event_cache.exhausted
			loop
				e := event_cache.item
				logfile.put_string (event_information (e))
				logfile.put_string ("%N")
				event_cache.forth
			end
			logfile.close
		end

feature {NONE} -- Implementation - Hook routines

	specialized_user_report: STRING is
		do
			Result := "File name: " + name
		end

feature {NONE} -- Implementation

	logfile: PLAIN_TEXT_FILE

end -- EVENT_LOG_FILE
