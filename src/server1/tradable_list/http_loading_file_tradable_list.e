indexing
	description:
		"FILE_BASED_TRADABLE_LISTs that originally obtain their tradable %
		%data via an http GET request and cache the data by saving it to a %
		%file.  The file is then read for processing by MAS, as with a %
		%FILE_TRADABLE_LIST.  Once data for a tradable has been retrieved %
		%via the http, no new retrieval is done for that tradable until %
		%cached data is out of date according to user-configured settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class HTTP_LOADING_FILE_TRADABLE_LIST inherit

	FILE_BASED_TRADABLE_LIST
		rename
			make as parent_make
		redefine
			timing_on, ignore_cache, update_and_load_data
		end

	HTTP_DATA_RETRIEVAL
		rename
			initialize as http_initialize
		redefine
			output_file_path, latest_date_for, latest_date_requirement
		end

	ERROR_PROTOCOL
		export
			{NONE} all
		end

	EXCEPTIONS
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (factory: TRADABLE_FACTORY; file_ext: STRING) is
		require
			valid_factory: factory /= Void
		local
			l: LIST [STRING]
		do
timing_on := True --!!!Check timing for a while.
			http_initialize
			if file_ext /= Void then file_extension := file_ext end
			l := symbols_from_file
			if l = Void then
				fatal_error := True
				raise (Initialization_error)
			else
				parent_make (l, factory)
				file_names := file_names_from_symbols
				file_names.start
			end
		ensure
			symbol_and_file_lists_set_if_no_error: not fatal_error implies
				symbol_list /= Void and file_names /= Void
		end

feature -- Access

	file_names: LIST [STRING]
			-- Names of all files with tradable data to be processed

	update_and_load_data is
		local
			data_file_exists, data_out_of_date: BOOLEAN
		do
			parameters.set_symbol (current_symbol)
			data_file_exists := True
			if last_tradable /= Void then
				-- Ensure that old indicator data from the previous
				-- `last_tradable' is not re-used.
				last_tradable.flush_indicators
				data_out_of_date := current_data_is_out_of_date
				if data_out_of_date and not output_file_exists then
					log_error_with_token (Data_file_does_not_exist_error,
						current_symbol)
					data_file_exists := False
				end
			else	-- last_tradable = Void
				if not output_file_exists then
					data_file_exists := False
					data_out_of_date := True
				else
					load_data
					data_out_of_date := current_data_is_out_of_date
				end
			end
			if not fatal_error and data_out_of_date then
				if data_file_exists then
					-- !!!!!!!Set alternate start date.
				end
				retrieve_data
				load_data
			end
		ensure then
			good_if_no_error: not fatal_error implies
				last_tradable /= Void and not current_data_is_out_of_date
		end

	old_retrieve_load_code_remove_me is --!!!!!!
		do
--OLD:
					setup_input_medium
					if fatal_error and not output_file_exists then
						-- `setup_input_medium' failed because the data for
						-- the current tradable has not yet been retrieved.
						retrieve_data
					end
					if not fatal_error then
--!!!!!May need to guard against side effects.
						load_data
						close_input_medium
					else
						-- A fatal error indicates that the current tradable
						-- is invalid, or not readable, or etc., so ensure
						-- that last_tradable is not set to this invalid
						-- object.
						last_tradable := Void
					end
--END-OLD
		end

	old_item_remove_me: TRADABLE [BASIC_MARKET_TUPLE] is --!!!!!!
			-- Current tradable.  `fatal_error' will be true if an error
			-- occurs.
		do
			fatal_error := false
			-- Create a new tradable (or get it from the cache) only if
			-- caching is off, or the cursor has moved since the last
			-- tradable creation, or the cache has been cleared.
			if
				not caching_on or
				index /= old_index or (Cache_size > 0 and cache.count = 0)
			then
				old_index := 0
				last_tradable := cached_item (index)
				if last_tradable = Void then
					setup_input_medium
					if fatal_error and not output_file_exists then
						-- `setup_input_medium' failed because the data for
						-- the current tradable has not yet been retrieved.
						retrieve_data
					end
					if not fatal_error then
--!!!!!May need to guard against side effects.
						load_data
						close_input_medium
					else
						-- A fatal error indicates that the current tradable
						-- is invalid, or not readable, or etc., so ensure
						-- that last_tradable is not set to this invalid
						-- object.
						last_tradable := Void
					end
				else
					-- Ensure that old indicator data from the previous
					-- `last_tradable' is not re-used.
					last_tradable.flush_indicators
				end
				old_index := index
			end
			Result := last_tradable
			if Result = Void and not fatal_error then
				fatal_error := true
			end
		ensure then
			good_if_no_error: not fatal_error implies Result /= Void
		end

feature -- Status setting

	set_timing_on (arg: BOOLEAN) is
			-- Set `timing_on' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			timing_on := arg
		ensure
			timing_on_set: timing_on = arg and timing_on /= Void
		end

feature {NONE} -- Implementation

	file_names_from_symbols: LIST [STRING] is
		require
			symbols_set: symbols /= Void
		do
			create {LINKED_LIST [STRING]} Result.make
			from symbols.start until symbols.exhausted loop
				Result.extend (output_file_name (symbols.item))
				symbols.forth
			end
		end

--!!!!Remove or fix at cleanup time.
	old_open_current_file_remove: INPUT_FILE is
		do
			parameters.set_symbol (current_symbol)
			if last_tradable = Void then
				-- The input file for `current_symbol' has not yet been read.
				-- Since `latest_date_for' will be called indirectly by
				-- `data_retrieval_needed', set up for and call `load_data'
				-- to ensure, if the data file exists, last_tradable is set.
				create Result.make (file_names.item)
				if Result.exists then
					Result.open_read
					load_data
				end
			end
			if data_retrieval_needed then
				retrieve_data
			end
			report_timing
			if Result = Void then
--now invalid:				Result := Precursor
			end
		end

feature {NONE} -- Hook routine implementations

	timing_on: BOOLEAN

	output_file_path: STRING is
			-- Directory path of output file - redefine if needed
		once
			--!!!!!Stub - implement this to use MAS_DIRECTORY env. var.
			--and perhaps within a ./data subdirectory.
			Result := ""
		end

	latest_date_for (symbol: STRING): DATE is
		local
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
print ("latest_date_for called.%N")
			search_by_symbol (symbol)
			t := last_tradable
			if
				t /= Void and then not t.data.is_empty
			then
				Result := t.data.last.end_date
print ("latest_date_for result: " + Result.out + "%N")
			end
		end

	ignore_cache: BOOLEAN is
		do
			Result := time_to_eod_update and not parameters.ignore_today and
				latest_date_for (current_symbol) < create {DATE}.make_now
		end

	latest_date_requirement: BOOLEAN is
		do
			Result := last_tradable /= Void
		ensure
			last_tradable_set_condition: Result = (last_tradable /= Void)
		end

invariant

end
