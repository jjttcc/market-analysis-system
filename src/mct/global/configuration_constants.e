indexing
	description: "Constants used for processing configuration files"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
		%License to be determined"

class

	CONFIGURATION_CONSTANTS

feature -- Access

	Comment_character: CHARACTER is '#'
			-- Character that, when occurring at the beginning of a line,
			-- denotes a comment

	Token_start_delimiter: CHARACTER is '<'
			-- Delimiter indicating the start of a replacable token

	Token_end_delimiter: CHARACTER is '>'
			-- Delimiter indicating the end of a replacable token

	Begin_tag: STRING is "begin"
			-- Tag denoting beginning of a "block"

	End_tag: STRING is "end"
			-- Tag denoting ending of a "block"

	Slash: STRING is "/"
			-- Slash character

	Backslash: STRING is "\"
			-- Backslash character

	Escape_character: STRING is "~"
			-- "Escape" character - protects the following character from
			-- being interpreted.

	True_string: STRING is "true"
			-- Value used to specify 'true' for a boolean setting

	False_string: STRING is "false"
			-- Value used to specify 'false' for a boolean setting

end
