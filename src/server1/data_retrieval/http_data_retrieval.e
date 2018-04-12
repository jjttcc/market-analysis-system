note
    description:
        "Abstraction of an algorithm for retrieving tradable data %
        %from a web site with the HTTP GET construct"
    author: "Jim Cochrane"
    note1: "@@Note: It may be appropriate at some point to change the name %
        %of this class to something like EXTERNAL_DATA_RETRIEVAL - %
        %tools and algorithms for retrieval of data from an external %
        %source - http, socket, etc - Much of the existing logic in this %
        %class (and in HTTP_CONFIGURATION - see equivalent note in that %
        %class) can probably be applied (as is or with little change) to %
        %retrieval from other external sources besides an http server."
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

    HTTP_DATA_RETRIEVAL

inherit

    GENERAL_UTILITIES
        export
            {NONE} all
            {ANY} deep_twin, is_deep_equal, standard_is_equal
        end

    TIMING_SERVICES
        export
            {NONE} all
        end

feature {NONE} -- Initialization

    initialize
        do
            create parameters.make
            create url.http_make (parameters.host, "")
            if parameters.proxy_used then
                set_proxy
            end
            create http_request.make (url)
            http_request.set_read_mode
            file_extension := Default_file_extension
        ensure
            components_initialized: parameters /= Void and url /= Void and
                http_request /= Void and file_extension /= Void
        end

feature {NONE} -- Attributes

    parameters: HTTP_CONFIGURATION

    url: SETTABLE_HTTP_URL

    http_request: HTTP_PROTOCOL

    file_extension: STRING
            -- Extension to file name of output cache file

    Default_file_extension: STRING = "txt"
            -- Default value for `file_extension'

feature {NONE} -- Basic operations

    retrieve_data
            -- Retrieve data for `parameters.symbol'.
        do
            retrieval_failed := False
            append_to_output_file := False
            http_request.reset_error
            if
                use_day_after_latest_date_as_start_date and
                alternate_start_date /= Void
            then
                url.set_path (parameters.path_with_alternate_start_date (
                    alternate_start_date))
                append_to_output_file := True
            else
                url.set_path (parameters.path)
            end
            -- Prevent a side effect re. alternate_start_date for the next
            -- call to retrieve_data.
            alternate_start_date := Void
            start_timer
            debug ("http")
                print ("url.path: " + url.path + "%N")
                print ("url.address: " + url.address + "%N")
            end
			perform_http_retrieval
        ensure
            output_file_exists_if_successful: not retrieval_failed and
                converted_result /= Void and then
                not converted_result.is_empty implies output_file_exists
            alternate_start_date_reset_to_void: alternate_start_date = Void
        end

    check_if_data_is_out_of_date
            -- Check if the current data for `parameters'.symbol are out
            -- of date with respect to the current date and the http
            -- configuration.  If True, `data_out_of_date' is set to True
            -- and `alternate_start_date' is set to the day after the date
            -- of the latest current data.
        local
            eod_update_time: BOOLEAN
            latest_date: DATE
        do
            --@@NOTE: This algorithm is for EOD data.  If the ability to
            --handle intraday data is added, a separate algorithm will
            --be needed for that.
            data_out_of_date := False
            alternate_start_date := Void
            eod_update_time := time_to_eod_update
            latest_date := latest_date_for (parameters.symbol)
            if latest_date /= Void then
                if not eod_update_time or parameters.ignore_today then
                    -- This path catches the case where it's not time
                    -- to EOD-update or it's a weekend, but the cached
                    -- data is not up to date with the latest trading day
                    -- before today.
                    data_out_of_date := latest_date <
                        parameters.latest_tradable_date_before_today
                else
                    check
                        update_time: eod_update_time and
                        not parameters.ignore_today
                    end
                    data_out_of_date := create {DATE}.make_now > latest_date
                end
                if data_out_of_date then
                    -- Set the alternate start date to the day after the
                    -- latest date in the current data set so that there
                    -- is no overlap between the current data set and
                    -- freshly retrieved data.  Clone to prevent side effects.
                    alternate_start_date := latest_date.twin
                    alternate_start_date.day_add (1)
                end
            end
        ensure
            data_out_of_date = (alternate_start_date /= Void)
        end

feature {NONE} -- Status report

    retrieval_failed: BOOLEAN
            -- Did the last call to `retrieve_data' fail?

    work_outputfile: PLAIN_TEXT_FILE

    output_file_exists: BOOLEAN
            -- Does the output file with name
            -- `output_file_name (parameters.symbol)' exist?
        do
            if work_outputfile = Void then
                create work_outputfile.make (
                    output_file_name (parameters.symbol))
            else
                work_outputfile.make (output_file_name (parameters.symbol))
            end
            Result := work_outputfile.exists
        end

    data_out_of_date: BOOLEAN
            -- Are data for the current symbol (`parameters.symbol')
            -- out of date with respect to today's date?

    converted_result: STRING
            -- Retrieval result converted into the expected format
            -- by `convert_and_save_result'

    output_file_name (symbol: STRING): STRING
            -- Output file name constructed from `symbol'
        local
            env: expanded OPERATING_ENVIRONMENT
            path: DIRECTORY
            ep: expanded ERROR_PROTOCOL
        do
            --@NOTE: If retrieval of intraday data via http is introduced,
            --a bit of redesign will be needed - Perhaps use an 'intraday'
            --flag and use a different extension for intraday than for
            --daily data.  Need to coordinate with other dependent
            --MAS components.
            create path.make (output_file_path)
            if not path.exists then
                path.create_dir
            end
            Result := path.name + env.directory_separator.out + symbol +
                "." + file_extension
        rescue
            log_errors (<<ep.Data_cache_directory_creation_failure_error, ": ",
                output_file_path, ".%N">>)
        end

    symbols_from_file: DYNAMIC_LIST [STRING]
            -- List of symbols read from the specified input file.
        require
            parameters_exist: parameters /= Void
        local
            file_reader: FILE_READER
            contents, separator: STRING
            su: expanded STRING_UTILITIES
            l: ARRAYED_LIST [STRING]
        do
            create file_reader.make (parameters.symbol_file)
            contents := file_reader.contents
            if not file_reader.error then
                if not contents.is_empty then
                    if contents.has ('%R') then
                        -- DOS-style text, with "%R%N" line termination
                        separator := "%R%N"
                    else
                        -- UNIX-style text, with "%N" line termination
                        separator := "%N"
                    end
                    su.set_target (contents)
                    l := su.tokens (separator)
                    if not l.is_empty and then l.last.is_empty then
                        -- If the last line of the l file ends with
                        -- a newline, `l' will have an empty last
                        -- element - remvoe it.
                        l.finish
                        l.remove
                    end
                else
                    create l.make (0)
                end
            else
                log_errors (<<"Error reading symbol file: ",
                    parameters.symbol_file, "%N(", 
                    file_reader.error_string, ")%N">>)
            end
            Result := l
        end

    convert_and_save_result (s: STRING)
            -- Convert the retrieved data in `s' to MAS format and save the
            -- result to a file named parameters.symbol"."file_extension.
        require
            symbol_valid: parameters /= Void and then parameters.symbol /=
                Void and then not parameters.symbol.is_empty
        local
            file: PLAIN_TEXT_FILE
        do
            start_timer
            if
                s /= Void and then
                parameters.post_processing_routine /= Void
            then
                add_timing_data ("Opening file for " + parameters.symbol)
                start_timer
                converted_result :=
                    parameters.post_processing_routine.item ([s])
                add_timing_data ("Converting data for " + parameters.symbol)
                if
                    converted_result = Void or else converted_result.is_empty
                then
                    log_error ("Result for " + parameters.symbol +
                        " is empty - symbol may be invalid.%N")
                else
                    start_timer
                    if append_to_output_file then
                        create file.make_open_append (output_file_name (
                            parameters.symbol))
                    else
                        create file.make_open_write (output_file_name (
                            parameters.symbol))
                    end
                    file.put_string (converted_result)
                    add_timing_data ("Writing data to " + file.name)
                    file.close
                end
            end
        end

    time_to_eod_update: BOOLEAN
            -- Is it time to update end-of-day data according to the
            -- `parameters.eod_turnover_time' specification?
        do
            if parameters.eod_turnover_time = Void then
                -- No turnover time specified - always update.
                Result := True
            else
                Result := create {TIME}.make_now > parameters.eod_turnover_time
            end
        end

    alternate_start_date: DATE
            -- Alternate start date to use instead of parameters.start_date -
            -- allows overriding the configured start date when, for
            -- example, data beginning at the configured start date has
            -- already been retrieved (i.e., retrieval is an update).
            -- Void indicates no alternate start date is being used.

    append_to_output_file: BOOLEAN
            -- Should retrieved data be appended to the output file
            -- rather than overwriting it?

feature {NONE} -- Hook routines

    output_file_path: STRING
            -- Directory path of output file
        once
            Result := "." -- Default to current directory - redefine if needed.
        ensure
            exists: Result /= Void
        end

    latest_date_for (symbol: STRING): DATE
            -- The latest date-stamp of the data cached for `symbol',
            -- for determining if this data is "out of date" -
            -- Void indicates that it should NOT be considered out of date.
            -- NOTE: If the result needs to be modified by the caller,
            -- make sure a clone of the result is modified rather than
            -- the actual result to prevent unwanted side effects.
        require
            symbol_exists: symbol /= Void
            latest_date_requirement: latest_date_requirement
        once
            -- Default to Void - redefine if needed.
        end

    use_day_after_latest_date_as_start_date: BOOLEAN
            -- When a retrieval is needed because
            -- check_if_data_is_out_of_date set data_out_of_date to True,
            -- should the day after the latest date of the current data set be
            -- used as the start date for retrieval so that there is no overlap
            -- between the current data set and freshly retrieved data?
        once
            Result := True -- Redefine if needed.
        end

    latest_date_requirement: BOOLEAN
            -- Precondition for `latest_date_for'
        once
            Result := True -- Redefine if a specific condition is needed.
        end

feature {NONE} -- Implementation

    perform_http_retrieval
        local
            result_string: STRING
            ex: expanded EXCEPTION_SERVICES
        do
            if not http_request.error then
                http_request.open
                if not http_request.error then
                    create result_string.make (0)
                    from
                        http_request.initiate_transfer
                    until
                        not http_request.is_packet_pending or
                        http_request.error
                    loop
                        http_request.read
                        result_string.append_string (http_request.last_packet)
                    end
                    if http_request.error then
                        print ("Error occurred initiating transfer: " +
                            http_request.error_text (http_request.error_code) +
                            "%N")
                        retrieval_failed := True
                    else
                        convert_and_save_result (result_string)
                    end
                    http_request.close
                else
                    print ("Error occurred opening http request: " +
                        http_request.error_text (http_request.error_code) +
                        "%N")
                    retrieval_failed := True
                    if http_request.is_open then
                        http_request.close
                    end
                end
                add_timing_data ("Retrieving data for " + parameters.symbol)
            else
                print ("Error occurred initializing http request: " +
                    http_request.error_text (http_request.error_code) +
                    "%N")
                retrieval_failed := True
            end
        ensure
            output_file_exists_if_successful: not retrieval_failed and
                converted_result /= Void and then
                not converted_result.is_empty implies output_file_exists
        rescue
            if http_request.error then
                ex.last_exception_status.set_description (
                    http_request.error_text (http_request.error_code))
            end
        end

    set_proxy
            -- Set url's proxy
        require
            attributes_exist: url /= Void and parameters /= Void
            proxy_used: parameters.proxy_used
        local
            port: INTEGER
            ex: expanded EXCEPTION_SERVICES
        do
            if
                url.proxy_host_ok (parameters.proxy_address) and
                parameters.proxy_port_number.is_integer
            then
                port := parameters.proxy_port_number.to_integer
                if port >= 0 then
                    url.set_proxy (parameters.proxy_address, port)
                else
                    ex.last_exception_status.set_description (
                        "Proxy port number is less than 0: '" +
                        port.out + "'.")
                    ex.raise ("")
                end
            else
                if url.proxy_host_ok (parameters.proxy_address) then
                    ex.last_exception_status.set_description (
                        "Proxy port number is not a number: '" +
                        parameters.proxy_port_number + "'.")
                else
                    ex.last_exception_status.set_description (
                        "Proxy port address is invalid: " +
                        parameters.proxy_address + ".")
                end
                ex.raise ("")
            end
        end

end
