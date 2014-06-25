note
	description:
		"File-related routines redefined for the Windows port"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	WINDOWS_FILE

feature -- Cursor movement

	back
			-- Do nothing - back needs to be ignored in the Windows version.
		do
		end

end -- WINDOWS_FILE
