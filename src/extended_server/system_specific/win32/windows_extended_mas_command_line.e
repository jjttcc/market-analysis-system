indexing
	description: "MAS_COMMAND_LINE for Windows, with extensions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class WINDOWS_EXTENDED_MAS_COMMAND_LINE inherit

	EXTENDED_MAS_COMMAND_LINE
		rename
			make as emcl_make
		end

	WINDOWS_MAS_COMMAND_LINE
		rename
			make as wmcl_make
		end

creation

	make

feature {NONE} -- Initialization

	make is
		do
			emcl_make
			windows_make
		end

invariant

end
