indexing
	description: "Environment variable values used by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class APP_ENVIRONMENT inherit

	EXECUTION_ENVIRONMENT

	OPERATING_ENVIRONMENT

feature -- Access

	app_directory: STRING is
			-- Full path of the working directory for the application -
			-- where configuration and data files are stored.
			-- Void if the associated environment variable is not set.
		once
			Result := get (env_names.item.application_directory_name)
		end

	mailer: STRING is
			-- Name of the executable to use for sending email
		once
			Result := get (env_names.item.mailer_name)
		end

	mailer_subject_flag: STRING is
			-- The flag to use to indicate to the mailer that the following
			-- argument is the subject
		once
			Result := get (env_names.item.mailer_subject_flag_name)
		end

	file_name_with_app_directory (fname: STRING): STRING is
			-- A full path name constructed from `app_directory' and `fname'
		require
			not_void: fname /= Void
		do
			!!Result.make (0)
			if app_directory /= Void and not app_directory.empty then
				Result.append (app_directory)
				Result.extend (Directory_separator)
			end
			Result.append (fname)
		end

feature -- Status setting

	set_env_name_service (arg: APP_ENVIRONMENT_VARIABLE_NAMES) is
			-- Set env_name_service to `arg'.
		require
			arg_not_void: arg /= Void
		do
			env_names.set_item (arg)
		ensure
			env_name_item_set: env_names.item = arg
		end

feature {NONE} -- Implementation

	env_names: SINGLE [APP_ENVIRONMENT_VARIABLE_NAMES] is
			-- Provides names of required environment variables
		local
			default_app_env_names: APP_ENVIRONMENT_VARIABLE_NAMES
		once
			!!default_app_env_names
			!!Result.make_item (default_app_env_names)
		end

end -- APP_ENVIRONMENT
