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

class FILE_TRADABLE_LIST inherit

    FILE_BASED_TRADABLE_LIST
        rename
            make as parent_make
        redefine
            retrieve_tradable_data, add_symbol, remove_symbol
        end

creation

    make

feature -- Initialization

    make (fnames: DYNAMIC_LIST [STRING]; factory: TRADABLE_FACTORY)
            -- `symbols' will be created from `fnames'
        local
            slist: LINKED_LIST [STRING]
            first: STRING
        do
            file_extension := ""
            file_names := fnames
            first := file_names.first
            if file_names.count > 0 then
                if first.has_substring(".") then
                    file_extension := first.substring(
                        first.substring_index(".", 1), first.count)
                end
            end
            create slist.make
            from fnames.start until fnames.exhausted loop
                slist.extend (symbol_from_file_name (fnames.item))
                fnames.forth
            end
            file_names.start
            parent_make (slist, factory)
        ensure
            symbols_set_from_fnames:
                symbols /= Void and symbols.count = fnames.count
            file_names_set: file_names = fnames
        end

feature -- Access

    file_names: DYNAMIC_LIST [STRING]
            -- Names of all files with tradable data to be processed

    external_data_service_active: BOOLEAN = True

feature {NONE} -- Implementation

    retrieve_tradable_data (symbol: STRING)
        local
            cmd: POSIX_EXEC_PROCESS
            env: expanded APP_ENVIRONMENT
        do
            create cmd.make(env.data_retrieval_script_path, <<symbol>>)
            cmd.execute
            cmd.wait_for (True)
            if cmd.exit_code /= 0 then
                fatal_error := True
                log_errors(<<"Retrieval of data for " + symbol + " failed",
                    " (exit code: " + cmd.exit_code.out + ")%N">>)
            end
        end

    file_extension: STRING

    add_symbol (symbol: STRING)
        do
            -- Insert at the beginning of the list(s):
            symbol_list.put_front(symbol)
            -- Force recloning of symbol_list:
            symbol_list_clone := Void
            file_names.put_front(symbol + file_extension)
            symbol_list.start
            file_names.start
        end

    remove_symbol (symbol: STRING)
        do
            symbol_list.start
            file_names.start
            symbol_list.prune_all(symbol)
            symbol_list_clone := Void
            file_names.prune_all(symbol + file_extension)
        end

end -- class FILE_TRADABLE_LIST
