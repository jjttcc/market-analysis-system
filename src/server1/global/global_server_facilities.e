indexing
	description: "Global features needed by the server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class

	GLOBAL_SERVER

feature -- Access

	sessions: HASH_TABLE [SESSION, INTEGER] is
			-- Registered GUI Client sessions
		once
			create Result.make(1)
		end

	command_line_options: MAS_COMMAND_LINE is
		once
			create Result.make
		end

	database_services: MAS_DB_SERVICES is
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.database_services
		end

	database_configuration: MAS_DB_INFO is
		once
			create Result.make
		end

	file_name_expander: FILE_NAME_EXPANDER is
		local
			platform_factory: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			Result := platform_factory.file_name_expander
		end

end -- GLOBAL_SERVER
