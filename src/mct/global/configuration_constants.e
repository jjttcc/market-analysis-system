note
	description: "Constants used for processing configuration files"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	CONFIGURATION_CONSTANTS

feature -- Access

	Comment_character: CHARACTER = '#'
			-- Character that, when occurring at the beginning of a line,
			-- denotes a comment

	Token_start_delimiter: CHARACTER = '<'
			-- Delimiter indicating the start of a replacable token

	Token_end_delimiter: CHARACTER = '>'
			-- Delimiter indicating the end of a replacable token

	Begin_tag: STRING = "begin"
			-- Tag denoting beginning of a "block"

	End_tag: STRING = "end"
			-- Tag denoting ending of a "block"

	Slash: STRING = "/"
			-- Slash character

	Backslash: STRING = "\"
			-- Backslash character

	Escape_character: STRING = "~"
			-- "Escape" character - protects the following character from
			-- being interpreted.

	True_string: STRING = "true"
			-- Value used to specify 'true' for a boolean setting

	False_string: STRING = "false"
			-- Value used to specify 'false' for a boolean setting

end
