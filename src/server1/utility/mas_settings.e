indexing
	description: "Information about the settings of the current MAS process"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_SETTINGS inherit

creation

	make

feature {NONE} -- Initialization

	make is
		local
			gs: expanded GLOBAL_SERVER_FACILITIES
		do
			command_line := gs.command_line_options
		end

feature -- Access

	command_line: MAS_COMMAND_LINE
			-- The command line from which the setting states are queried

	data_source_report: STRING is
			-- Report on data-source settings
		local
			env: expanded APP_ENVIRONMENT
			constants: expanded APPLICATION_CONSTANTS
		do
			if command_line.use_db then
				Result := "Obtaining data from a database " +
					"management system.%NDatabase configuration file:%N"
				if env.db_config_file_name /= Void then
					Result.append (env.file_name_with_app_directory (
							env.db_config_file_name))
				else
					Result.append (env.file_name_with_app_directory (
						constants.Default_database_config_file_name))
				end
			else
				if command_line.use_external_data_source then
					Result := "Obtaining data from an external data source."
				elseif command_line.use_web then
					Result := "Obtaining data from a web server."
				else
					Result := "Obtaining data from files."
				end
				Result := Result +
					"%NStock split file:%N"
				if env.stock_split_file_name /= Void then
					Result.append (env.file_name_with_app_directory (
							env.stock_split_file_name))
				else
					Result.append (env.file_name_with_app_directory (
						constants.Default_stock_split_file_name))
				end
			end
		end

	app_directory_report: STRING is
			-- Report on the application directory (MAS_DIRECTORY)
		local
			env: expanded APP_ENVIRONMENT
			var_names: expanded APP_ENVIRONMENT_VARIABLE_NAMES
		do
			if env.app_directory = Void then
				Result := "Application directory " +
					"variable (" + var_names.application_directory_name +
					") is not set."
			else
				Result := "Application directory " +
					"(" + var_names.application_directory_name +
					"):%N" + env.app_directory + ""
			end
		end

	working_directory_report: STRING is
			-- Report on current working directory
		local
			env: expanded APP_ENVIRONMENT
		do
			if env.current_working_directory /= Void then
				Result := "Current working directory:%N" +
					env.current_working_directory + ""
			else
				Result := "Current working directory is not available."
			end
		end

	email_report: STRING is
			-- Report on email-related settings
		local
			env: expanded APP_ENVIRONMENT
			constants: expanded APPLICATION_CONSTANTS
		do
			if env.mailer /= Void then
				Result := "Mailer: " + env.mailer
			else
				Result := "Mailer: " + constants.Default_mailer
			end
			if env.mailer_subject_flag /= Void then
				Result.append ("%NMailer subject flag: " +
					env.mailer_subject_flag)
			else
				Result.append ("%NMailer subject flag: " +
					constants.Default_mailer_subject_flag)
			end
		end

invariant

	command_line_set: command_line /= Void

end
