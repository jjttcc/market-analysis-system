note
	description: "Information about the settings of the current MAS process"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MAS_SETTINGS inherit

	ANY
		redefine
			default_create
		end

creation

	default_create

feature {NONE} -- Initialization

	default_create
		local
			gs: expanded GLOBAL_SERVER_FACILITIES
		do
			command_line := gs.command_line_options
		end

feature -- Access

	command_line: MAS_COMMAND_LINE
			-- The command line from which the setting states are queried

	process_report: STRING
			-- Report process info.
		local
			gsf: expanded GLOBAL_SERVER_FACILITIES
		do
			Result := "Process was started at " + gsf.startup_date_time.out
		end

	data_source_report: STRING
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
							env.db_config_file_name, True))
				else
					Result.append (env.file_name_with_app_directory (
						constants.Default_database_config_file_name, False))
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
							env.stock_split_file_name, False))
				else
					Result.append (env.file_name_with_app_directory (
						constants.Default_stock_split_file_name, False))
				end
			end
		end

	app_directory_report: STRING
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

	working_directory_report: STRING
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

	email_report: STRING
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

	local_host_name_report: STRING
			-- Report - host name on which this process is running
		do
			Result := "Host name: " + local_host_name
		ensure
			exists: Result /= Void
		end

	connection_cache_size: STRING
			-- Report - size of connection cache
		local
			cache_size: INTEGER
			env: expanded APP_ENVIRONMENT
			app_constants: expanded APPLICATION_CONSTANTS
		do
			cache_size := env.connection_cache_size
			if cache_size <= 0 then
				cache_size := app_constants.default_connection_cache_size
			end
			Result := "Socket connection cache size: " + cache_size.out
		ensure
			exists: Result /= Void
		end

	miscellaneous_report: STRING
			-- Report on miscellaneous information
		local
			gsf: expanded GLOBAL_SERVER_FACILITIES
		do
			Result := "Cache size: " +
				gsf.global_configuration.tradable_cache_size.out
			if command_line.allow_non_standard_period_types then
				Result := Result + "%NNon-standard period types allowed."
			end
			Result := Result + "%N" + connection_cache_size
		end

	close_socket_report: STRING
			-- Report on status of no_close_after_each_send query
		local
			env: expanded APP_ENVIRONMENT
		do
			if env.no_close_after_each_send then
				Result := "Socket connection will NOT be closed after each" +
					" request/response exchange"
			else
				Result := "Socket connection will be closed after each" +
					" request/response exchange"
			end
		end


	ports_report: STRING
			-- Report on all port numbers being used
		do
			Result := "Port numbers: "
			from
				command_line.port_numbers.start
			until
				command_line.port_numbers.islast or
				command_line.port_numbers.exhausted
			loop
				Result := Result + command_line.port_numbers.item.out + ", "
				command_line.port_numbers.forth
			end
			if command_line.port_numbers.islast then
				Result := Result + command_line.port_numbers.item.out
			else
				Result := Result + " (None)"
			end
			command_line.port_numbers.start
		ensure
			exists: Result /= Void
		end

	local_host_name: STRING
		do
			Result := (create {HOST_ADDRESS}.make).local_host_name
			if Result = Void then
				Result := ""
			end
		ensure
			exists: Result /= Void
		end

invariant

	command_line_set: command_line /= Void

end
