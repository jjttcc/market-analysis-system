indexing
	description: "Allowed values for a 'command menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMAND_MENU_VALUES inherit

	OBJECT_MENU_VALUES

feature -- Access

	edit: CHARACTER is 'e'
		-- Constant for 'edit' selection

	edit_u: CHARACTER is 'E'
		-- Constant for 'edit' selection, uppercase

	type_name: STRING is "command"

invariant

end
