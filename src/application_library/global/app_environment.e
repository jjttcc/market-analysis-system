indexing
	description: "Environment variable values used by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TAL_APP_ENVIRONMENT inherit

	EXECUTION_ENVIRONMENT

	OPERATING_ENVIRONMENT

feature -- Access

	app_directory: STRING is
			-- Full path of the working directory for the application -
			-- where configuration and data files are stored.
		once
			Result := get ("TAL_APP_DIRECTORY")
		ensure
			not_void_if_env_var_is_set:
				Result = Void or Result.is_equal (get ("TAL_APP_DIRECTORY"))
		end

	mailer: STRING is
			-- Name of the executable to use for sending email
		once
			Result := get ("TAL_APP_MAILER")
		ensure
			set_correctly_if_env_var_is_set:
				Result = Void or Result.is_equal (get ("TAL_APP_MAILER"))
		end

	mailer_subject_flag: STRING is
			-- The flag to use to indicate to the mailer that the following
			-- argument is the subject
		once
			Result := get ("TAL_APP_MAILER_SUBJECT_FLAG")
		ensure
			set_correctly_if_env_var_is_set:
				Result = Void or
					Result.is_equal (get ("TAL_APP_MAILER_SUBJECT_FLAG"))
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

end -- TAL_APP_ENVIRONMENT
