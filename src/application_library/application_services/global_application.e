note
	description: "Global features needed by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class GLOBAL_APPLICATION inherit

--!!!!old:	EXCEPTIONS
	EXCEPTION_SERVICES
		export
			{NONE} all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	TRADABLE_FACILITIES
		export
			{NONE} all
		end

	CLEANUP_SERVICES
		export
			{NONE} all
		end

feature -- Access

	event_types: ARRAY [EVENT_TYPE]
			-- All event types known to the system - in an array.
		local
			i: INTEGER
		do
			create {ARRAY [EVENT_TYPE]} Result.make (1,
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

	event_types_by_key: HASH_TABLE [EVENT_TYPE, INTEGER]
			-- All event types known to the system in a hash table - key
			-- is the event type ID.
		do
			create Result.make (
				market_event_generation_library.count)
			from
				market_event_generation_library.start
			until
				market_event_generation_library.exhausted
			loop
				Result.extend (market_event_generation_library.item.event_type,
					market_event_generation_library.item.event_type.id)
				market_event_generation_library.forth
			end
		end

	create_event_generator (eg_maker: EVENT_GENERATOR_FACTORY;
				event_type_name: STRING;
				meg_list: STORABLE_LIST [MARKET_EVENT_GENERATOR])
			-- Create a new MARKET_EVENT_GENERATOR and a new associated
			-- EVENT_TYPE (with `event_type_name') and add the new
			-- MARKET_EVENT_GENERATOR  to `meg_list'.
		require
			not_void: eg_maker /= Void and event_type_name /= Void and
				meg_list /= Void
		do
			eg_maker.set_event_type (new_event_type (
				event_type_name, meg_list))
			eg_maker.execute
			meg_list.extend (eg_maker.product)
		ensure
			one_more_eg: meg_list.count =
				old meg_list.count + 1
			product_in_library: eg_maker.product /= Void and
				meg_list.has (eg_maker.product)
		end

	function_library: STORABLE_LIST [MARKET_FUNCTION]
			-- All defined market functions - Side effect:
			-- create_stock_function_library is called (once) to fill
			-- stock_function_library with valid (for a stock) members
			-- of function_library.
-- !!!! indexing once_status: global??!!!
		once
			Result := retrieved_function_library
		ensure
			not_void: Result /= Void
		end

	market_event_generation_library: STORABLE_LIST [MARKET_EVENT_GENERATOR]
			-- All defined event generators - Side effect:
			-- create_stock_market_event_generation_library is called (once)
			-- to fill stock_market_event_generation_library with valid
			-- (for a stock) members of function_library.
-- !!!! indexing once_status: global??!!!
		once
			Result := retrieved_market_event_generation_library
		ensure
			not_void: Result /= Void
		end

	market_event_registrants: STORABLE_LIST [MARKET_EVENT_REGISTRANT]
			-- All defined event registrants
-- !!!! indexing once_status: global??!!!
		once
			Result := retrieved_market_event_registrants
		ensure
			not_void: Result /= Void
		end

	active_event_generators: LIST [MARKET_EVENT_GENERATOR]
			-- Event generators in which at least one event registrant
			-- is interested.
		local
			registrants: LIST [MARKET_EVENT_REGISTRANT]
			generators: LIST [MARKET_EVENT_GENERATOR]
		do
			create {LINKED_LIST [MARKET_EVENT_GENERATOR]} Result.make
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
		ensure
			not_void: Result /= Void
		end

	meg_names (meg_lib: LIST [MARKET_EVENT_GENERATOR]):
				ARRAYED_LIST [STRING]
			-- Names of all elements of `meg_lib' if not Void; otherwise,
			-- of `market_event_generation_library', in the same order
		local
			meg_library: LIST [MARKET_EVENT_GENERATOR]
		do
			if meg_lib = Void then
				meg_library := market_event_generation_library
			else
				meg_library := meg_lib
			end
			from
				create Result.make (meg_library.count)
				meg_library.start
			until
				meg_library.exhausted
			loop
				Result.extend (
					meg_library.item.event_type.name)
				meg_library.forth
			end
		end

	function_names: ARRAYED_LIST [STRING]
			-- Names of all elements of `function_library', in the same order
		do
			create Result.make (function_library.count)
			from
				function_library.start
			until
				function_library.after
			loop
				Result.extend (function_library.item.name)
				function_library.forth
			end
		end

	event_type_names: ARRAYED_LIST [STRING]
			-- Names of all elements of `event_types', in the same order
		local
			etypes: LINEAR [EVENT_TYPE]
		do
			create Result.make (event_types.count)
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

feature -- Basic operations

	force_function_library_retrieval
			-- Force function library to be re-retrieved by deep copying
			-- `retrieved_function_library' into it.
		do
			deep_copy_list (function_library, retrieved_function_library)
		end

	force_meg_library_retrieval
			-- Force market event generator library to be re-retrieved by deep
			-- copying `retrieved_market_event_generation_library' into it.
		do
			deep_copy_list (market_event_generation_library,
				retrieved_market_event_generation_library)
		end

	force_event_registrant_retrieval
			-- Force event registrants to be re-retrieved by deep copying
			-- `retrieved_market_event_registrants' into it.
		do
			deep_copy_list (market_event_registrants,
				retrieved_market_event_registrants)
		end

feature -- Constants

	indicators_file_name: STRING
			-- Name of the file containing persistent data for indicators
		note
			once_status: global
		once
			Result := "indicators_persist"
		end

	generators_file_name: STRING
			-- Name of the file containing persistent data for event generators
		note
			once_status: global
		once
			Result := "generators_persist"
		end

	registrants_file_name: STRING
			-- Name of the file containing persistent data for event
			-- registrants
		note
			once_status: global
		once
			Result := "registrants_persist"
		end

	future_years: INTEGER = 100
			-- Number of years in the future for `future_date' and
			-- `future_date_time'

	future_date: DATE
			-- A date some time in the future - used to implement an
			-- "eternal now" (a date that will always be larger than any
			-- realistic market tuple date)
		note
			once_status: global
		once
			create Result.make_now
			Result.set_year (Result.year + future_years)
		ensure
			exists: Result /= Void
		end

	future_date_time: DATE_TIME
			-- A date/time some time in the future - used to implement an
			-- "eternal now" (a date/time that will always be larger than any
			-- realistic market tuple date)
		note
			once_status: global
		once
			create Result.make_now
			Result.date.set_year (Result.year + future_years)
		ensure
			exists: Result /= Void
		end

feature {NONE} -- Implementation

	retrieved_function_library: STORABLE_LIST [MARKET_FUNCTION]
		local
			storable: STORABLE
			mflist: STORABLE_LIST [MARKET_FUNCTION]
			retrieval_failed: BOOLEAN
			app_env: expanded APP_ENVIRONMENT
			full_path_name: STRING
		do
			full_path_name := app_env.file_name_with_app_directory (
				indicators_file_name, False)
			if retrieval_failed then
				if exception = Retrieve_exception then
					log_errors (<<"Retrieval of indicator library file ",
						full_path_name, " failed.%N", file_errinfo>>)
				else
					log_errors (<<"Error occurred while retrieving indicator %
						%%Nlibrary file (", meaning(exception), "):%N",
						full_path_name, "%N", file_errinfo>>)
				end
				handle_exception ("")
			else
				create storable
				mflist ?= storable.retrieve_by_name (full_path_name)
				if mflist = Void then
					create {STORABLE_MARKET_FUNCTION_LIST} mflist.make (
						indicators_file_name)
				end
				Result := mflist
			end
			create_stock_function_library (Result)
		ensure
			not_void: Result /= Void
		rescue
			retrieval_failed := True
			retry
		end

	retrieved_market_event_generation_library:
				STORABLE_LIST [MARKET_EVENT_GENERATOR]
			-- All defined event generators
		local
			storable: STORABLE
			meg_list: STORABLE_LIST [MARKET_EVENT_GENERATOR]
			retrieval_failed: BOOLEAN
			app_env: expanded APP_ENVIRONMENT
			full_path_name: STRING
		do
			full_path_name := app_env.file_name_with_app_directory (
				generators_file_name, False)
			if retrieval_failed then
				if exception = Retrieve_exception then
					log_errors (<<"Retrieval of market analysis library%
						% file ", full_path_name, " failed.%N", file_errinfo>>)
				else
					log_errors (<<"Error occurred while retrieving market %
						%analysis library (", meaning(exception),
							").%N", file_errinfo>>)
				end
				handle_exception ("")
			else
				create storable
				meg_list ?= storable.retrieve_by_name (full_path_name)
				if meg_list = Void then
					create {STORABLE_EVENT_GENERATOR_LIST} meg_list.make (
						generators_file_name)
				end
				Result := meg_list
			end
			create_stock_market_event_generation_library (Result)
		rescue
			retrieval_failed := True
			retry
		end

	retrieved_market_event_registrants:
				STORABLE_LIST [MARKET_EVENT_REGISTRANT]
			-- All defined event registrants
		local
			storable: STORABLE
			reg_list: STORABLE_LIST [MARKET_EVENT_REGISTRANT]
			retrieval_failed: BOOLEAN
			app_env: expanded APP_ENVIRONMENT
			full_path_name: STRING
		do
			full_path_name := app_env.file_name_with_app_directory (
				registrants_file_name, False)
			if retrieval_failed then
				if exception = Retrieve_exception then
					log_errors (<<"Retrieval of event registrants file ",
						full_path_name, " failed.%N", file_errinfo>>)
				else
					log_errors (<<"Error occurred while retrieving event %
						%registrants (", meaning(exception),
						").%N", file_errinfo>>)
				end
				handle_exception ("")
			else
				create storable
				reg_list ?= storable.retrieve_by_name (full_path_name)
				if reg_list = Void then
					create reg_list.make (registrants_file_name)
				end
				Result := reg_list
			end
		rescue
			retrieval_failed := True
			retry
		end

	stock_function_library: LIST [MARKET_FUNCTION]
			-- Members of `function_library' that are valid for stocks
-- !!!! indexing once_status: global??!!!
		once
			create {LINKED_LIST [MARKET_FUNCTION]} Result.make
		end

	create_stock_function_library (l: LIST [MARKET_FUNCTION])
			-- Create `stock_function_library' and place all members of
			-- `l' that are `valid_stock_processor's into it.
		do
			stock_function_library.wipe_out
			from l.start until l.exhausted loop
				if valid_stock_processor (l.item) then
					stock_function_library.extend (l.item)
				end
				l.forth
			end
		end

	stock_market_event_generation_library: LIST [MARKET_EVENT_GENERATOR]
			-- Members of `market_event_generation_library' that are valid
			-- for stocks
-- !!!! indexing once_status: global??!!!
		once
			create {LINKED_LIST [MARKET_EVENT_GENERATOR]} Result.make
		end

	create_stock_market_event_generation_library (
		l: LIST [MARKET_EVENT_GENERATOR])
			-- Create `stock_market_event_generation_library' and place all
			-- members of `l' that are `valid_stock_processor's into it.
		do
			stock_market_event_generation_library.wipe_out
			from l.start until l.exhausted loop
				if valid_stock_processor (l.item) then
					stock_market_event_generation_library.extend (l.item)
				end
				l.forth
			end
		end

	new_event_type (name: STRING;
		meg_library: STORABLE_LIST [MARKET_EVENT_GENERATOR]): EVENT_TYPE
			-- Create a new EVENT_TYPE with name `name' and a unique ID -
			-- and ID that does not occur in `meg_library', or if
			-- `meg_library' is Void, that does not occur in
			-- `market_event_generation_library'.
			-- Note: A new MARKET_EVENT_GENERATOR should be created with
			-- this new event type and added to market_event_generation_library
			-- before the next event type is created.
		require
			not_void: name /= Void and meg_library /= Void
		local
			unique_id: INTEGER
			l: LIST [MARKET_EVENT_GENERATOR]
		do
			l := meg_library
			unique_id := maximum_id_value (l) + 1
			create Result.make (name, unique_id)
		ensure
			new_type: not event_types_by_key.has (Result.id)
		end

	maximum_id_value (l: LIST [MARKET_EVENT_GENERATOR]): INTEGER
			-- The largest EVENT_TYPE ID value in `l'
		do
			from
				Result := 1
				l.start
			until
				l.exhausted
			loop
				if l.item.event_type.id > Result then
					Result := l.item.event_type.id
				end
				l.forth
			end
		end

	file_errinfo: STRING
			-- Standard error message for problems loading from files
		do
			Result := "The file may be corrupted or you may have %
				%an incompatible version.%N"
		end

end -- GLOBAL_APPLICATION
