indexing
	description: "Global entities needed by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_APPLICATION

feature {NONE} -- Utility

	current_date: DATE is
		do
			!!Result.make_now
		end

	current_time: TIME is
		do
			!!Result.make_now
		end

	register_for_termination (v: TERMINABLE) is
			-- Add `v' to termination_registrants.
		require
			not_registered: not termination_registrants.has (v)
		do
			termination_registrants.extend (v)
		end

	termination_cleanup is
			-- Send cleanup notification to all members of
			-- `termination_registrants'.
		do
			from
				termination_registrants.start
			until
				termination_registrants.exhausted
			loop
				termination_registrants.item.cleanup
				termination_registrants.forth
			end
		end

feature {NONE} -- Access

	termination_registrants: LIST [TERMINABLE] is
			-- Registrants for termination cleanup notification
		once
			!LINKED_LIST [TERMINABLE]!result.make
		end

	--!!!Probably, event type stuff should go into a separate class.
	--!!!GS may use that class to make them globally available.
	--event_types: TABLE [EVENT_TYPE, INTEGER] is
	event_types: ARRAY [EVENT_TYPE] is
			-- All event types known to the system
		once
			!ARRAY [EVENT_TYPE]!Result.make (1, 0)
		end

	create_event_type (name: STRING) is
			-- Create a new EVENT_TYPE with name `name' and add it to
			-- the `event_types' table.
			--!!!More design work needed here re. event type management.
		local
			et: EVENT_TYPE
			i: INTEGER
		do
			i := last_event_ID.item + 1
			last_event_ID.set_item (i)
			!!et.make (name, last_event_ID.item)
			event_types.force (et, last_event_ID.item)
		end

	last_event_type: EVENT_TYPE is
			-- Last created event type
		do
			if last_event_ID.item > 0 then
				Result := event_types @ last_event_ID.item
			end
		end

	last_event_ID: INTEGER_REF is
			-- !!!Temporary hack
		once
			!!Result
			Result.set_item (0)
		end

	function_library: LIST [MARKET_FUNCTION] is
			-- All defined market functions
		local
			storable: STORABLE
			mflist: STORABLE_LIST [MARKET_FUNCTION]
		once
			!!storable
			mflist ?= storable.retrieve_by_name (storable_file_name)
			if mflist = Void then
				!STORABLE_MARKET_FUNCTION_LIST!mflist.make (
														storable_file_name)
			end
			register_for_termination (mflist)
			Result := mflist
		end

feature {NONE} -- Constants

	default_input_file_name: STRING is "/tmp/tatest"
			-- Name of default input file if none is specified by the user

	storable_file_name: STRING is
			-- Name of the file containing persistent data
		local
			ta_env: expanded TAL_APP_ENVIRONMENT
		once
			Result := ta_env.file_name_with_app_directory ("ta_persist")
		end

end -- GLOBAL_APPLICATION
