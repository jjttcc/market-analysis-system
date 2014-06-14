note
	description: "Environment variable values used by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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

feature {NONE} -- Implementation

	env_names: APP_ENVIRONMENT_VARIABLE_NAMES
		note
			once_status: global
		once
			create Result
		end

end
