indexing
	description: "Global features needed by the application"
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
			-- `termination_registrants' in the order they were added
			-- (with `register_for_termination').
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
			-- Ensure that the list will be saved when the process ends.
			register_for_termination (mflist)
			Result := mflist
		end

	market_event_generation_library: LIST [MARKET_EVENT_GENERATOR] is
			-- All defined event generators
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
			-- Ensure that the list will be saved when the process ends.
			register_for_termination (meg_list)
			Result := meg_list
		end

	active_event_generators: LIST [MARKET_EVENT_GENERATOR] is
			-- Event generators in which at least one event registrant
			-- is interested in.
		local
			registrants: LIST [MARKET_EVENT_REGISTRANT]
			generators: LIST [MARKET_EVENT_GENERATOR]
		do
			!LINKED_LIST [MARKET_EVENT_GENERATOR]!Result.make
			registrants := market_event_registrants
			generators := market_event_generation_library
			from
				registrants.start
			until
				registrants.exhausted
			loop
				from
					generators.start
				until
					generators.exhausted
				loop
					if
						-- If the current generator has not already been
						-- added to Result and the current registrant is
						-- intersted in that generator's event type, add
						-- it to Result.
						not Result.has (generators.item) and
							registrants.item.event_types.has (
								generators.item.event_type)
					then
						Result.extend (generators.item)
					end
					generators.forth
				end
				registrants.forth
			end
		end

	market_event_registrants: LIST [MARKET_EVENT_REGISTRANT] is
			-- All defined event registrants
		local
			storable: STORABLE
			reg_list: STORABLE_LIST [MARKET_EVENT_REGISTRANT]
		once
			!!storable
			reg_list ?= storable.retrieve_by_name (registrants_file_name)
			if reg_list = Void then
				!!reg_list.make (registrants_file_name)
			end
			Result := reg_list
			-- The registrants themselves also need to be registered for
			-- termination/cleanup when the process ends; and they need
			-- to load their (event) histories, which are stored in
			-- a separate file.
			from
				Result.start
			until
				Result.exhausted
			loop
				Result.item.load_history
				register_for_termination (Result.item)
				Result.forth
			end
			-- Ensure that the list will be saved when the process ends.
			-- This is done after registering the contents of the list
			-- because the MERs need to be cleaned up before being saved
			-- as elements of reg_list (since cleanup is done for each
			-- termination registrant in the order it was registered).
			register_for_termination (reg_list)
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
