indexing
	description: "Global features needed by the server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	GLOBAL_SERVER

feature -- Access

	sessions: HASH_TABLE [MAS_SESSION, INTEGER] is
			-- Registered GUI Client sessions
		once
			create Result.make(1)
		end

	command_line_options: MAS_COMMAND_LINE is
			-- Command-line option services
		once
			create Result.make
		end

	database_services: MAS_DB_SERVICES is
			-- Database services
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.database_services
		end

	database_configuration: DATABASE_CONFIGURATION is
			-- Database configuration settings
		once
			create Result.make
		end

	file_name_expander: FILE_NAME_EXPANDER is
			-- File name expander for current OS
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.file_name_expander
		end

	file_lock (file_name: STRING): FILE_LOCK is
			-- File locking services
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		do
			Result := platform_factory.file_lock (file_name)
		end

end -- GLOBAL_SERVER
