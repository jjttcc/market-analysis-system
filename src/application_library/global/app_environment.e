note
    description: "Environment variable values used by the application"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    --settings: vim: expandtab:

class APP_ENVIRONMENT inherit

    EXECUTION_ENVIRONMENT
        export
            {NONE} all
            {ANY} current_working_directory, deep_twin, is_deep_equal,
                standard_is_equal
        end

    OPERATING_ENVIRONMENT
        export
            {NONE} all
        end

feature -- Access

    app_directory: STRING
            -- Path of the working directory for the application -
            -- where configuration and data files are stored.
            -- Void if the associated environment variable is not set.
        note
            once_status: global
        once
            Result := get (env_names.application_directory_name)
        end

    stock_split_file_name: STRING
            -- Name of the file containing stock split data, if any
            -- Void if the associated environment variable is not set.
        note
            once_status: global
        once
            Result := get (env_names.stock_split_file_name)
        end

    db_config_file_name: STRING
            -- Name of the database configuration file, if any
            -- Void if the associated environment variable is not set.
        note
            once_status: global
        once
            Result := get (env_names.db_config_file_name)
        end

    mailer: STRING
            -- Name of the executable to use for sending email
        note
            once_status: global
        once
            Result := get (env_names.mailer_name)
        end

    mailer_subject_flag: STRING
            -- The flag to use to indicate to the mailer that the following
            -- argument is the subject
        note
            once_status: global
        once
            Result := get (env_names.mailer_subject_flag_name)
        end

    no_close_after_each_send: BOOLEAN
            -- Should the server refrain from closing the socket connection
            -- after each send (response)?
        note
            once_status: global
        local
            no_close_val: STRING
        once
            Result := False
            no_close_val := get (env_names.no_close_name)
            if no_close_val /= Void then
                Result := True
            end
        end

    connection_cache_size: INTEGER
            -- Size of the socket-connection cache - 0 if not set or invalid
        note
            once_status: global
        local
            sz: STRING
        once
            Result := 0
            sz := get (env_names.connection_cache_size_name)
            if sz /= Void and then sz.is_integer then
                Result := sz.to_integer
            end
        end

    debug_level: INTEGER
            -- Level for control of debugging output:
            --   0 or not set => none
            --   1            => basic
            --   2            => verbose
            --   3            => extremely verbose
            -- If the <debug_level_name> environment variable is set to
            -- a value that cannot be converted to a non-negative integer,
            -- the result will be 0.
            -- 0 if the associated environment variable is not set.
        note
            once_status: global
        local
            value: STRING
        once
            Result := 0
            value := get (env_names.debug_level_name)
            if value /= Void then
                if value.is_integer then
                    Result := value.to_integer
                    if Result < 0 then
                        Result := 0
                    end
                end
            end
        end

    file_name_with_app_directory (fname: STRING; use_absolute_path: BOOLEAN):
        STRING
            -- A full path name constructed from `app_directory' and `fname' -
            -- If `use_absolute_path' and `fname' starts with a directory
            -- separator, interpret `fname' as an absolute path instead
            -- of preceding it with `app_directory'.
        require
            not_void: fname /= Void
        do
            create Result.make (0)
            if
                not (use_absolute_path and not fname.is_empty and
                fname @ 1 = Directory_separator) and
                app_directory /= Void and not app_directory.is_empty
            then
                Result.append (app_directory)
                Result.extend (Directory_separator)
            end
            Result.append (fname)
        ensure
            absolute_path_condition: (use_absolute_path and
                not fname.is_empty and fname @ 1 = Directory_separator) implies
                equal (Result, fname)
        end

    data_retrieval_script_path: STRING
        note
            once_status: global
        once
            if app_directory = Void then
                Result := "." + Directory_separator.out
            else
                Result := app_directory + Directory_separator.out
            end
            Result := Result + "scripts" + Directory_separator.out +
                data_retrieval_script_name
        ensure
            Result /= Void and not Result.is_empty
        end

    data_retrieval_script_name: STRING = "retrieve_tradable_data.rb"

feature {NONE} -- Implementation

    env_names: APP_ENVIRONMENT_VARIABLE_NAMES
        note
            once_status: global
        once
            create Result
        end

end
