indexing
	description: "Environment variable values used by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class APP_ENVIRONMENT inherit

	EXECUTION_ENVIRONMENT

	OPERATING_ENVIRONMENT

feature -- Access

	app_directory: STRING is
			-- Path of the working directory for the application -
			-- where configuration and data files are stored.
			-- Void if the associated environment variable is not set.
		once
			Result := get (env_names.application_directory_name)
		end

	stock_split_file_name: STRING is
			-- Name of the file containing stock split data, if any
			-- Void if the associated environment variable is not set.
		once
			Result := get (env_names.stock_split_file_name)
		end

	db_config_file_name: STRING is
			-- Name of the database configuration file, if any
			-- Void if the associated environment variable is not set.
		once
			Result := get (env_names.db_config_file_name)
		end

	mailer: STRING is
			-- Name of the executable to use for sending email
		once
			Result := get (env_names.mailer_name)
		end

	mailer_subject_flag: STRING is
			-- The flag to use to indicate to the mailer that the following
			-- argument is the subject
		once
			Result := get (env_names.mailer_subject_flag_name)
		end

	file_name_with_app_directory (fname: STRING): STRING is
			-- A full path name constructed from `app_directory' and `fname'
		require
			not_void: fname /= Void
		do
			create Result.make (0)
			if app_directory /= Void and not app_directory.is_empty then
				Result.append (app_directory)
				Result.extend (Directory_separator)
			end
			Result.append (fname)
		end

feature {NONE} -- Implementation

	env_names: APP_ENVIRONMENT_VARIABLE_NAMES is
		once
			create Result
		end

end
