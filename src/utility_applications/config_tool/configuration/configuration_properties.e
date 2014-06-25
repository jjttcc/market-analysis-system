note
	description: "Constants and other properties used for processing the %
		%configuration file"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CONFIGURATION_PROPERTIES inherit

--	CONFIGURATION_CONSTANTS
--		export
--			{NONE} all
--		end

feature -- Access

	Replacement_specifier: STRING = "replace"

	Start_specifier: STRING = "start"

	End_specifier: STRING = "end"

	Comment_character: CHARACTER = '#'

end
