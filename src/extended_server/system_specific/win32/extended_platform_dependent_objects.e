note
	description: "Builder of platform-dependent objects for the extended %
		%version of MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class EXTENDED_PLATFORM_DEPENDENT_OBJECTS inherit

feature -- Access

	command_line: WINDOWS_EXTENDED_MAS_COMMAND_LINE
		do
			create Result.make
		end

end
