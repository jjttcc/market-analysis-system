indexing
	description: "Builder of objects that are platform-dependent"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class PLATFORM_DEPENDENT_OBJECTS inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	database_services: MAS_DB_SERVICES is
		do
--!!!!!!!Need to create three windows versions of this class - one that
--uses ODBC_SERVICES, one that uses ECLI_SERVICES, and one that uses
--DB_SERVICES_STUB.
			create {DB_SERVICES_STUB} Result.make
-- create {ODBC_SERVICES} Result.make
			if Result.fatal_error then
				log_errors (<<"Fatal database error: ",
					Result.last_error, ".%N">>)
			end
		end

	file_name_expander: FILE_NAME_EXPANDER is
		do
			create {WINDOWS_FILE_NAME_EXPANDER} Result
		end

	file_lock (file_name: STRING): FILE_LOCK is
		do
			-- The file-locking mechanism for Windows is not yet
			-- working, so use a "fake" lock for now.
			create {BASIC_FILE_LOCK} Result.make (file_name)
		end

end -- class PLATFORM_DEPENDENT_OBJECTS
