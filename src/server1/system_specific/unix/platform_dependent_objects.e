indexing
	description: "Builder of objects that are platform-dependent"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class PLATFORM_DEPENDENT_OBJECTS

feature -- Access

	database_services: MAS_DB_SERVICES is
		do
			create {ECLI_SERVICES} Result
		end

	file_name_expander: FILE_NAME_EXPANDER is
		do
			create {UNIX_FILENAME_EXPANDER} Result
		end

end -- class PLATFORM_DEPENDENT_OBJECTS
