indexing
	description: "Environment variable values used by the application"
	usage:
		"Configure the features of this class to return the appropriate %
		%values for the listed environment variable names."
	note:
		"It would be better to separate this configuration from the %
		%application_library by defining a class that inherits from this %
		%one and redefines these features, but I could not figure out a %
		%way to do this and make these values globally available %
		%via once functions (without getting a segmentation violation - %
		%may be a bug in the ISE compiler)."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class APP_ENVIRONMENT_VARIABLE_NAMES

feature -- Access

	application_directory_name: STRING is
			-- Default name of the application directory environment variable
		do
			Result := "MAS_DIRECTORY"
		end

	stock_split_file_name: STRING is
			-- Default name of the stock_split_file_name environment variable
		do
			Result := "MAS_STOCK_SPLIT_FILE"
		end

	db_config_file_name: STRING is
			-- Default name of the database config file
			-- environment variable
		do
			Result := "MAS_DB_CONFIG_FILE"
		end

	mailer_name: STRING is
			-- Default name of the environment variable for the executable
			-- to use for sending email
		do
			Result := "MAS_MAILER"
		end

	mailer_subject_flag_name: STRING is
			-- Default name of the environment variable for the flag
			-- to use to indicate to the mailer that the following
			-- argument is the subject
		do
			Result := "MAS_MAILER_SUBJECT_FLAG"
		end

end -- APP_ENVIRONMENT_VARIABLE_NAMES
