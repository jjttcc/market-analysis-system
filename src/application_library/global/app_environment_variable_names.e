indexing
	description: "Environment variable values used by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class APP_ENVIRONMENT_VARIABLE_NAMES

feature -- Access

	application_directory_name: STRING is
			-- Default name of the application directory environment variable
		do
			Result := "TAL_APP_DIRECTORY"
		end

	mailer_name: STRING is
			-- Default name of the environment variable for the executable
			-- to use for sending email
		do
			Result := "TAL_APP_MAILER"
		end

	mailer_subject_flag_name: STRING is
			-- Default name of the environment variable for the flag
			-- to use to indicate to the mailer that the following
			-- argument is the subject
		do
			Result := "TAL_APP_MAILER_SUBJECT_FLAG"
		end

end -- APP_ENVIRONMENT_VARIABLE_NAMES
