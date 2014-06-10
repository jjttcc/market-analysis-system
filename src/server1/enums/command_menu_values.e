note
	description: "Allowed values for a 'command menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMAND_MENU_VALUES inherit

	OBJECT_MENU_VALUES

feature -- Access

	edit: CHARACTER = 'e'
		-- Constant for 'edit' selection

	edit_u: CHARACTER = 'E'
		-- Constant for 'edit' selection, uppercase

	type_name: STRING = "command"

invariant

end
