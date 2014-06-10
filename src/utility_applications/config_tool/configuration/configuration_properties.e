note
	description: "Constants and other properties used for processing the %
		%configuration file"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
		%License to be determined"

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
