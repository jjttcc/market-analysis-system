indexing
	description: "Constants used for processing configuration files"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	GENERAL_CONFIGURATION_CONSTANTS

feature -- Access

	Comment_character: CHARACTER is '#'
			-- Character that, when occurring at the beginning of a line,
			-- denotes a comment

	token_start_delimiter: CHARACTER is '<'
			-- Delimiter indicating the start of a replacable token

	token_end_delimiter: CHARACTER is '>'
			-- Delimiter indicating the end of a replacable token

end
