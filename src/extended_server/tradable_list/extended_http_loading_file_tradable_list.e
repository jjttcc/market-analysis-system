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

class EXTENDED_HTTP_LOADING_FILE_TRADABLE_LIST inherit

	EXTENDED_FILE_BASED_TRADABLE_LIST
		rename
			make as efbfl_make
		undefine
			load_target_tradable
		redefine
			target_tradable_out_of_date
		select
			target_tradable_out_of_date
		end

	HTTP_LOADING_FILE_TRADABLE_LIST
		rename
			make as http_make,
			target_tradable_out_of_date as http_out_of_date
		undefine
			start, finish, back, forth, turn_caching_off, clear_cache,
			add_to_cache, setup_input_medium, close_input_medium,
			remove_current_item, append_new_data
		select
			fbtl_make
		end

creation

	make

feature -- Initialization

	make (factory: TRADABLE_FACTORY; file_ext: STRING)
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

	target_tradable_out_of_date: BOOLEAN
		do
			Result := http_out_of_date and then
				Precursor {EXTENDED_FILE_BASED_TRADABLE_LIST}
		end

end
