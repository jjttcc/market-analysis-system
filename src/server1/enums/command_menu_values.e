note
	description: "Allowed values for a 'command menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
