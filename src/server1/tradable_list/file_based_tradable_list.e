note
    description:
        "TRADABLE_LISTs that obtain their input data from files"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class FILE_BASED_TRADABLE_LIST inherit

    INPUT_MEDIUM_BASED_TRADABLE_LIST
        redefine
            start, forth, finish, back, remove_current_item, input_medium
        end

    TIMING_SERVICES
        export
            {NONE} all
        end

feature -- Access

    file_names: LIST [STRING]
            -- Names of all files with tradable data to be processed
        deferred
        end

    external_data_service_active: BOOLEAN
        deferred
        end

feature -- Cursor movement

    start
        do
            file_names.start
            Precursor
        end

    finish
        do
            file_names.finish
            Precursor
        end

    forth
        do
            file_names.forth
            Precursor
        end

    back
        do
            file_names.back
            Precursor
        end

feature {NONE} -- Implementation

    remove_current_item
        do
            file_names.prune (file_names.item)
            Precursor
            if not symbol_list.off then
                file_names.go_i_th (symbol_list.index)
            end
        end

    initialize_input_medium
        local
            file: INPUT_FILE
        do
            create {OPTIMIZED_INPUT_FILE} file.make (file_names.item)
            input_medium := file
            if file.exists then
                file.open_read
            elseif external_data_service_active then
                retrieve_tradable_data(symbol_from_file_name(file.name))
                if not fatal_error then
                    -- Now that the file actually exists, "remake" and open it:
                    create {OPTIMIZED_INPUT_FILE} file.make (file_names.item)
                    input_medium := file
                    if file.exists then
                        file.open_read
                    else
                        --!!!!!To-do: Log unlikely error!!!
                    end
                end
            else
                log_errors (<<"Failed to open input file ",
                    file_names.item, " - file does not exist.%N">>)
                fatal_error := True
            end
        end

    input_medium: INPUT_FILE

    retrieve_tradable_data (symbol: STRING)
        require
            symbol: symbol /= Void
            external_data: external_data_service_active
        do
            -- (Implement in descendants in which
            --  `external_data_service_active` is true.)
        end

feature {NONE} -- Implementation - utilities

    symbol_from_file_name (fname: STRING): STRING
            -- Tradable symbol extracted from `fname' - directory component
            -- and suffix ('.' and all characters that follow it) of the
            -- file name are removed.  `fname' is not changed.
        local
             strutil: expanded STRING_UTILITIES
        do
            strutil.set_target (fname.twin)
            if strutil.target.has (Directory_separator) then
                -- Strip directory path from the file name:
                strutil.keep_tail (Directory_separator)
            end
            if strutil.target.has ('.') then
                -- Strip off "suffix":
                strutil.keep_head ('.')
            end
            Result := strutil.target
        end

invariant

    file_names_correspond_to_symbols:
        file_names /= Void and symbols.count = file_names.count
    file_names_and_symbol_list: symbol_list.index = file_names.index

end
