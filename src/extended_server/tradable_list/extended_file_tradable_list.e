note
    description:
        "An abstraction that provides a virtual list of tradables by %
        %holding a list that contains the input data file name of each %
        %tradable and loading the current tradable from its input file, %
        %giving the illusion that it is iterating over a list of tradables %
        %in memory.  The purpose of this scheme is to avoid using the %
        %large amount of memory that would be required to hold a large %
        %list of tradables in memory at once."
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class EXTENDED_FILE_TRADABLE_LIST inherit

    EXTENDED_FILE_BASED_TRADABLE_LIST
        rename
            make as tl_make1
        undefine
            retrieve_tradable_data, add_symbol, remove_symbol
        select
            tl_make1
        end

    FILE_TRADABLE_LIST
        rename
            parent_make as tl_make2,
            make as ftl_make
        export
            {NONE} tl_make2, ftl_make
        undefine
            start, finish, back, forth, turn_caching_off, clear_cache,
            add_to_cache, setup_input_medium, close_input_medium,
            remove_current_item, target_tradable_out_of_date,
            append_new_data
        end

creation

    make

feature -- Initialization

    make (fnames: DYNAMIC_LIST [STRING]; factory: TRADABLE_FACTORY)
            -- `symbols' will be created from `fnames'
        do
            ftl_make (fnames, factory)
            create file_status_cache.make (cache_size)
        ensure
            symbols_set_from_fnames:
                symbols /= Void and symbols.count = fnames.count
            file_names_set: file_names = fnames
        end

end
