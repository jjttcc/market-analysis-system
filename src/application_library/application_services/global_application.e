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

	event_types: ARRAY [EVENT_TYPE] is
			-- All event types known to the system
		local
			i: INTEGER
		do
			!ARRAY [EVENT_TYPE]!Result.make (1,
				market_event_generation_library.count)
			from
				i := 1
				market_event_generation_library.start
			until
				market_event_generation_library.exhausted
			loop
				Result.put (market_event_generation_library.item.event_type, i)
				market_event_generation_library.forth
				i := i + 1
			end
		end

	new_event_type (name: STRING): EVENT_TYPE is
			-- Create a new EVENT_TYPE with name `name'.
			-- !!!with a unique ID - not in m_e_g_l ...
			-- Note: A new MARKET_EVENT_GENERATOR should be created with
			-- this new event type and added to market_event_generation_library
			-- before the next event type is created.
		do
			!!Result.make (name, market_event_generation_library.count + 1)
		ensure
			not event_types.has (Result)
		end

	function_library: LIST [MARKET_FUNCTION] is
			-- All defined market functions
		local
			storable: STORABLE
			mflist: STORABLE_LIST [MARKET_FUNCTION]
		once
			!!storable
			mflist ?= storable.retrieve_by_name (indicators_file_name)
			if mflist = Void then
				!STORABLE_MARKET_FUNCTION_LIST!mflist.make (
					indicators_file_name)
			end
			register_for_termination (mflist)
			Result := mflist
		end

	market_event_generation_library: LIST [MARKET_EVENT_GENERATOR] is
			-- All defined market functions
		local
			storable: STORABLE
			meg_list: STORABLE_LIST [MARKET_EVENT_GENERATOR]
		once
			!!storable
			meg_list ?= storable.retrieve_by_name (generators_file_name)
			if meg_list = Void then
				!STORABLE_EVENT_GENERATOR_LIST!meg_list.make (
					generators_file_name)
			end
			register_for_termination (meg_list)
			Result := meg_list
		end

	market_event_registrants: LIST [MARKET_EVENT_REGISTRANT] is
			-- All defined market functions
		local
			storable: STORABLE
			reg_list: STORABLE_LIST [MARKET_EVENT_REGISTRANT]
		once
			!!storable
			reg_list ?= storable.retrieve_by_name (registrants_file_name)
			if reg_list = Void then
				!!reg_list.make (generators_file_name)
			end
			-- Registrants are registered for termination somewhere else.
			-- Should that be moved to here?
			Result := reg_list
		end

feature {NONE} -- Constants

	default_input_file_name: STRING is "/tmp/tatest"
			-- Name of default input file if none is specified by the user

	indicators_file_name: STRING is
			-- Name of the file containing persistent data for indicators
		local
			ta_env: expanded TAL_APP_ENVIRONMENT
		once
			Result := ta_env.file_name_with_app_directory ("indicators_persist")
		end

	generators_file_name: STRING is
			-- Name of the file containing persistent data for event generators
		local
			ta_env: expanded TAL_APP_ENVIRONMENT
		once
			Result := ta_env.file_name_with_app_directory ("generators_persist")
		end

	registrants_file_name: STRING is
			-- Name of the file containing persistent data for event generators
		local
			ta_env: expanded TAL_APP_ENVIRONMENT
		once
			Result := ta_env.file_name_with_app_directory (
						"registrants_persist")
		end

end -- GLOBAL_APPLICATION
