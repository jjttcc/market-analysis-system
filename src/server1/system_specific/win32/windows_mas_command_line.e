indexing
	description: "MAS_COMMAND_LINE adapted for Windows idiosyncrasies"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class WINDOWS_MAS_COMMAND_LINE inherit

	MAS_COMMAND_LINE
		rename
			make as mcl_make
		export
			{NONE} mcl_make
		end

creation {PLATFORM_DEPENDENT_OBJECTS}

	make

feature {NONE} -- Initialization

	make is
		do
			mcl_make
			-- There is a problem with the CONSOLE class in Windows, so
			-- force the system to always run in the "background" so that
			-- CONSOLE is not used.
			background := True
		end

end
