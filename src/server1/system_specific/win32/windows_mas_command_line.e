note
	description: "MAS_COMMAND_LINE adapted for Windows idiosyncrasies"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	make
		do
			mcl_make
			windows_make
		end

	windows_make
		do
			-- There is a problem with the CONSOLE class in Windows, so
			-- force the system to always run in the "background" so that
			-- CONSOLE is not used.
			background := True
		end

end
