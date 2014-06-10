note
	description: "Allowed values for an '<object> editing' selection - %
		%create, edit, remove, etc."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OBJECT_EDITING_VALUES inherit

feature -- Access

	creat: CHARACTER = 'c'
		-- Constant for 'create' selection

	creat_u: CHARACTER = 'C'
		-- Constant for 'create' selection, uppercase

	remove: CHARACTER = 'r'
		-- Constant for 'remove' selection

	remove_u: CHARACTER = 'R'
		-- Constant for 'remove' selection, uppercase

	edit: CHARACTER = 'e'
		-- Constant for 'edit' selection

	edit_u: CHARACTER = 'E'
		-- Constant for 'edit' selection, uppercase

	view: CHARACTER = 'v'
		-- Constant for 'view' selection

	view_u: CHARACTER = 'V'
		-- Constant for 'view' selection, uppercase

	sav: CHARACTER = 's'
		-- Constant for 'save' selection

	sav_u: CHARACTER = 'S'
		-- Constant for 'save' selection, uppercase

	previous: CHARACTER = '-'
		-- Constant for 'previous menu' selection

	shell_escape: CHARACTER = '!'
		-- Constant for 'shell escape' selection

end
