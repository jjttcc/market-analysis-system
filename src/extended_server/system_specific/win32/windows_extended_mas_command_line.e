note
	description: "MAS_COMMAND_LINE for Windows, with extensions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

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

	make
		do
			emcl_make
			windows_make
		end

invariant

end
