indexing
	description: "Abstraction for an event registrant that simply logs %
				%events to a file"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class EVENT_LOG_FILE inherit

	PLAIN_TEXT_FILE
		rename
			make as file_make_unused
		export {NONE}
			all
		end

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

feature -- Initialization

	make (fname, event_history_file_name: STRING) is
			-- Create the file with `fname' as the file `name' and
			-- `hfile_name' set to `event_history_file_name'
			-- Open this file, with `fname', for appending in the application
			-- environment directory, if set.
		require
			not_void_and_not_empty: fname /= Void and not fname.empty
		local
			talenv: TAL_APP_ENVIRONMENT
		do
			!!talenv
			hfile_name := event_history_file_name
			er_make
			-- Object comparison is required because of the persistence
			-- mechanism - on retrieval from storage a member of `event_types'
			-- may be a different instance than the respective member of
			-- `global_event_types'.  (Originally they will be the same
			-- instance.)
			event_types.compare_objects
			make_open_append (talenv.file_name_with_app_directory (fname))
		ensure
			names_set: name.is_equal (fname) and
				hfile_name.is_equal (event_history_file_name)
			appendable: is_open_append
		end

feature -- Basic operations

	perform_notify (elist: LIST [TYPED_EVENT]) is
		local
			e: TYPED_EVENT
		do
			from
				elist.start
			until
				elist.exhausted
			loop
				e := elist.item
				put_string (event_information (e))
				put_string ("%N")
				elist.forth
			end
		end

end -- EVENT_LOG_FILE
