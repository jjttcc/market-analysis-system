indexing
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

	Replacement_specifier: STRING is "replace"

	Start_specifier: STRING is "start"

	End_specifier: STRING is "end"

	Comment_character: CHARACTER is '#'

end
