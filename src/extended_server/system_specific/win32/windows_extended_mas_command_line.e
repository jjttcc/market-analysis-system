note
	description: "MAS_COMMAND_LINE for Windows, with extensions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
