indexing
	description:
		"File-related routines redefined for the Windows port"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	WINDOWS_FILE

feature -- Cursor movement

	back is
			-- Do nothing - back needs to be ignored in the Windows version.
		do
		end

end -- WINDOWS_FILE
