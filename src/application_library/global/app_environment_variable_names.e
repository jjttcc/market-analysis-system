note
	description: "Names of environment variables used by the application"
	usage:
		"Configure the features of this class to return the appropriate %
		%values for the listed environment variable names."
	note1:
		"It would be better to separate this configuration from the %
		%application_library by defining a class that inherits from this %
		%one and redefines these features, but I could not figure out a %
		%way to do this and make these values globally available %
		%via once functions (without getting a segmentation violation - %
		%may be a bug in the ISE compiler)."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class APP_ENVIRONMENT_VARIABLE_NAMES

feature -- Access

	application_directory_name: STRING
			-- Default name of the application directory environment variable
		do
			Result := "MAS_DIRECTORY"
		end

	stock_split_file_name: STRING
			-- Default name of the stock_split_file_name environment variable
		do
			Result := "MAS_STOCK_SPLIT_FILE"
		end

	db_config_file_name: STRING
			-- Default name of the database config file
			-- environment variable
		do
			Result := "MAS_DB_CONFIG_FILE"
		end

	mailer_name: STRING
			-- Default name of the environment variable for the executable
			-- to use for sending email
		do
			Result := "MAS_MAILER"
		end

	mailer_subject_flag_name: STRING
			-- Default name of the environment variable for the flag
			-- to use to indicate to the mailer that the following
			-- argument is the subject
		do
			Result := "MAS_MAILER_SUBJECT_FLAG"
		end

	no_close_name: STRING
			-- Name of the environment variable, which, if set, will cause
			-- the server to refrain from closing the socket after each
			-- send (i.e., after a response to a client request)
		do
			Result := "MAS_NO_CLOSE"
		end

	connection_cache_size_name: STRING
			-- Name of the environment variable, which, if set, will cause
			-- the server to refrain from closing the socket after each
			-- send (i.e., after a response to a client request)
		do
			Result := "MAS_CONN_CACHE_SIZE"
		end

	debug_level_name: STRING
			-- Name of environment variable that specifies a debug level
			-- for debugging output - expected to be a non-negative integer
		do
			Result := "MAS_DEBUG_LEVEL"
		end

end -- APP_ENVIRONMENT_VARIABLE_NAMES
