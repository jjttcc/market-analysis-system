note
	description: "Builder of platform-dependent objects for the extended %
		%version of MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXTENDED_PLATFORM_DEPENDENT_OBJECTS inherit

feature -- Access

	command_line: WINDOWS_EXTENDED_MAS_COMMAND_LINE
		do
			create Result.make
		end

end
