note
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
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class HTTP_LOADING_FILE_TRADABLE_LIST inherit

	FILE_BASED_TRADABLE_LIST
		rename
			make as fbtl_make
		export
			{ANY} cached_item
		redefine
			load_target_tradable, target_tradable_out_of_date,
			append_new_data
		end

	HTTP_DATA_RETRIEVAL
		rename
			initialize as http_initialize
		redefine
			output_file_path, latest_date_for, latest_date_requirement,
			use_day_after_latest_date_as_start_date
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

	make (factory: TRADABLE_FACTORY; file_ext: STRING)
		require
			valid_factory: factory /= Void
		local
			l: LIST [STRING]
		do
			http_initialize
			if file_ext /= Void then file_extension := file_ext end
			l := symbols_from_file
			if l = Void then
				fatal_error := True
				raise (Initialization_error)
			else
				fbtl_make (l, factory)
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

	external_data_service_active: BOOLEAN = False

feature {NONE} -- Implementation

	load_target_tradable
		do
			parameters.set_symbol (current_symbol)
			use_day_after_latest_date_as_start_date := True
			if not output_file_exists then
				data_out_of_date := True
			else
				load_data
				check_if_data_is_out_of_date
			end
			if not fatal_error and data_out_of_date then
				retrieve_data
				if not retrieval_failed and output_file_exists then
					load_data
				end
			end
		ensure then
			good_if_no_error: not fatal_error implies target_tradable /= Void
		end

	file_names_from_symbols: LIST [STRING]
		require
			symbols_set: symbols /= Void
		do
			create {LINKED_LIST [STRING]} Result.make
			from symbols.start until symbols.exhausted loop
				Result.extend (output_file_name (symbols.item))
				symbols.forth
			end
		end

feature {NONE} -- Hook routine implementations

	output_file_path: STRING
			-- Directory path of output file - redefine if needed
		note
			once_status: global
		local
			env: expanded APP_ENVIRONMENT
		once
			Result := env.file_name_with_app_directory (
				parameters.data_cache_subdirectory, False)
		end

	latest_date_for (symbol: STRING): DATE
		do
			if not current_symbol.is_equal (symbol) then
				search_by_symbol (symbol)
			end
			if
				target_tradable /= Void and then
					not target_tradable.data.is_empty
			then
				Result := target_tradable.data.last.end_date
			end
		end

	latest_date_requirement: BOOLEAN
		do
			Result := target_tradable /= Void
		ensure then
			target_tradable_set_condition: Result = (target_tradable /= Void)
		end

	use_day_after_latest_date_as_start_date: BOOLEAN

	target_tradable_out_of_date: BOOLEAN
		do
			parameters.set_symbol (current_symbol)
			use_day_after_latest_date_as_start_date := True
			check_if_data_is_out_of_date
			if data_out_of_date and not output_file_exists then
				log_error_with_token (Data_file_does_not_exist_error,
					current_symbol)
				use_day_after_latest_date_as_start_date := False
			end
			if not fatal_error and data_out_of_date then
				retrieve_data
				-- If `retrieval_failed', there is not new data - thus
				-- the target tradable is not out of date.
				Result := not retrieval_failed
			else
				check
					not_out_of_date: not Result
				end
			end
		end

	append_new_data
		do
			load_data
		end

end
