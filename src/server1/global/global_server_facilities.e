indexing
	description: "Global features needed by the server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	GLOBAL_SERVER_FACILITIES

feature -- Access

--!!!Needs to be made thread-safe or redesigned:
	sessions: HASH_TABLE [MAS_SESSION, INTEGER] is
			-- Registered GUI Client sessions
		indexing
			once_status: global
		once
			create Result.make(1)
		end

	command_line_options: MAS_COMMAND_LINE is
			-- Command-line option services
		indexing
			once_status: global
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.command_line
		end

	database_services: MAS_DB_SERVICES is
			-- Database services
--@@@Change to once per process?
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.database_services
		end

	database_configuration: DATABASE_CONFIGURATION is
			-- Database configuration settings
--@@@Change to once per process?
		once
			create Result.make
		end

	global_configuration: GLOBAL_CONFIGURATION is
			-- General, global configuration settings
		once
			Result := (create {CONFIGURATION_FACTORY}.make).global_configuration
		end

	file_name_expander: FILE_NAME_EXPANDER is
			-- File name expander for current OS
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.file_name_expander
		end

	startup_date_time: DATE_TIME is
			-- Date/time the process was started - Note: This feature must
			-- be called at start-up to set the result correctly, once.
		once
			create Result.make_now
		end

	file_lock (file_name: STRING): FILE_LOCK is
			-- File locking services
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		do
			Result := platform_factory.file_lock (file_name)
		end

end
