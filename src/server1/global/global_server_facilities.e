note
	description: "Global features needed by the server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	GLOBAL_SERVER_FACILITIES

feature -- Access

--!!!Needs to be made thread-safe or redesigned:
	sessions: HASH_TABLE [MAS_SESSION, INTEGER]
			-- Registered GUI Client sessions
		note
			once_status: global
		once
			create Result.make(1)
		end

	command_line_options: MAS_COMMAND_LINE
			-- Command-line option services
		note
			once_status: global
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.command_line
		end

	database_services: MAS_DB_SERVICES
			-- Database services
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.database_services
		end

	database_configuration: DATABASE_CONFIGURATION
			-- Database configuration settings
		once
			create Result.make
		end

	global_configuration: GLOBAL_CONFIGURATION
			-- General, global configuration settings
		once
			Result := (create {CONFIGURATION_FACTORY}.make).global_configuration
		end

	file_name_expander: FILE_NAME_EXPANDER
			-- File name expander for current OS
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.file_name_expander
		end

	startup_date_time: DATE_TIME
			-- Date/time the process was started - Note: This feature must
			-- be called at start-up to set the result correctly, once.
		once
			create Result.make_now
		end

	file_lock (file_name: STRING): FILE_LOCK
			-- File locking services
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		do
			Result := platform_factory.file_lock (file_name)
		end

end
