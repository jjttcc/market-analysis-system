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
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTENDED_HTTP_LOADING_FILE_TRADABLE_LIST inherit

	EXTENDED_FILE_BASED_TRADABLE_LIST
		rename
			make as efbfl_make
		undefine
			load_target_tradable
		redefine
			target_tradable_out_of_date
		end

	HTTP_LOADING_FILE_TRADABLE_LIST
		rename
			make as http_make
		undefine
			start, finish, back, forth, turn_caching_off, clear_cache,
			add_to_cache, setup_input_medium, close_input_medium,
			remove_current_item, target_tradable_out_of_date, append_new_data
		select
			fbtl_make
		end

creation

	make

feature -- Initialization

	make (factory: TRADABLE_FACTORY; file_ext: STRING) is
		require
			valid_factory: factory /= Void
		do
			http_make (factory, file_ext)
			create file_status_cache.make (cache_size)
		ensure
			symbol_and_file_lists_set_if_no_error: not fatal_error implies
				symbol_list /= Void and file_names /= Void
			file_status_cache_exists_if_no_error: not fatal_error implies
				file_status_cache /= Void
		end

feature -- Access

feature {NONE} -- Hook routine implementations

	target_tradable_out_of_date: BOOLEAN is
		do
			parameters.set_symbol (current_symbol)
			use_day_after_latest_date_as_start_date := True
-- !!!!??:
-- Ensure that old indicator data from the previous
-- `target_tradable' is not re-used.
target_tradable.flush_indicators
			check_if_data_is_out_of_date
			if data_out_of_date and not output_file_exists then
				log_error_with_token (Data_file_does_not_exist_error,
					current_symbol)
				use_day_after_latest_date_as_start_date := False
			end
			if not fatal_error and data_out_of_date then
				retrieve_data
			end
			Result := {EXTENDED_FILE_BASED_TRADABLE_LIST} Precursor
print ("target_tradable_out_of_date returning: " + Result.out + "%N")
		end

end
