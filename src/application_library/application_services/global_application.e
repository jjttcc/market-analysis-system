indexing
	description: "Global features needed by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class GLOBAL_APPLICATION inherit

	EXCEPTIONS
		export
			{NONE} all
		end

	PRINTING
		export
			{NONE} all
		end

feature -- Utility

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

feature -- Access

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

	create_event_generator (eg_maker: EVENT_GENERATOR_FACTORY;
				event_type_name: STRING) is
			-- Create a new MARKET_EVENT_GENERATOR and a new associated
			-- EVENT_TYPE (with `event_type_name') and add the new
			-- MARKET_EVENT_GENERATOR  to `market_event_generation_library'.
		require
			not_void: eg_maker /= Void and event_type_name /= Void
		do
			eg_maker.set_event_type (new_event_type (event_type_name))
			eg_maker.execute
			market_event_generation_library.extend (eg_maker.product)
		ensure
			one_more_eg: market_event_generation_library.count =
				old market_event_generation_library.count + 1
			product_in_library: eg_maker.product /= Void and
				market_event_generation_library.has (eg_maker.product)
		end

	function_library: LIST [MARKET_FUNCTION] is
			-- All defined market functions
		local
			storable: STORABLE
			mflist: STORABLE_LIST [MARKET_FUNCTION]
			retrieval_failed: BOOLEAN
		once
			if retrieval_failed then
				if exception = Retrieve_exception then
					print_list (<<"Retrieval of function library file ",
								indicators_file_name, " failed%N">>)
				else
					print_list (<<"Error occurred while retrieving function %
									%library: ", meaning(exception), "%N">>)
				end
				die (-1)
			else
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
		rescue
			retrieval_failed := true
			retry
		end

	market_event_generation_library: LIST [MARKET_EVENT_GENERATOR] is
			-- All defined event generators
		local
			storable: STORABLE
			meg_list: STORABLE_LIST [MARKET_EVENT_GENERATOR]
			retrieval_failed: BOOLEAN
		once
			if retrieval_failed then
				if exception = Retrieve_exception then
					print_list (<<"Retrieval of market analysis library%
								% file ", generators_file_name, " failed%N">>)
				else
					print_list (<<"Error occurred while retrieving market %
							%analysis library: ", meaning(exception), "%N">>)
				end
				die (-1)
			else
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
		rescue
			retrieval_failed := true
			retry
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
			retrieval_failed: BOOLEAN
		once
			if retrieval_failed then
				if exception = Retrieve_exception then
					print_list (<<"Retrieval of event registrants file ",
								registrants_file_name, " failed%N">>)
				else
					print_list (<<"Error occurred while retrieving event %
								%registrants: ", meaning(exception), "%N">>)
				end
				die (-1)
			else
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
		rescue
			retrieval_failed := true
			retry
		end

	meg_names: ARRAYED_LIST [STRING] is
			-- Names of all elements of `market_event_generation_library',
			-- in the same order
		local
			meg_library: LIST [MARKET_EVENT_GENERATOR]
		do
			meg_library := market_event_generation_library
			from
				!!Result.make (meg_library.count)
				meg_library.start
			until
				meg_library.exhausted
			loop
				Result.extend (
					meg_library.item.event_type.name)
				meg_library.forth
			end
		end

	function_names: ARRAYED_LIST [STRING] is
			-- Names of all elements of `function_library', in the same order
		do
			!!Result.make (function_library.count)
			from
				function_library.start
			until
				function_library.after
			loop
				Result.extend (function_library.item.name)
				function_library.forth
			end
		end

	event_type_names: ARRAYED_LIST [STRING] is
			-- Names of all elements of `event_types', in the same order
		local
			etypes: LINEAR [EVENT_TYPE]
		do
			!!Result.make (event_types.count)
			etypes := event_types.linear_representation
			from
				etypes.start
			until
				etypes.exhausted
			loop
				Result.extend (etypes.item.name)
				etypes.forth
			end
	end

feature -- Constants

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

feature {NONE} -- Implementation

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

	output_field_separator, output_date_field_separator,
	output_record_separator: STRING is
			-- Inherited from PRINTING
		once
			Result := ""
		end

end -- GLOBAL_APPLICATION
