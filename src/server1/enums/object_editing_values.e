indexing
	description: "Allowed values for an '<object> editing' selection - %
		%create, edit, remove, etc."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OBJECT_EDITING_VALUES inherit

feature -- Access

	creat: CHARACTER is 'c'
		-- Constant for 'create' selection

	creat_u: CHARACTER is 'C'
		-- Constant for 'create' selection, uppercase

	remove: CHARACTER is 'r'
		-- Constant for 'remove' selection

	remove_u: CHARACTER is 'R'
		-- Constant for 'remove' selection, uppercase

	edit: CHARACTER is 'e'
		-- Constant for 'edit' selection

	edit_u: CHARACTER is 'E'
		-- Constant for 'edit' selection, uppercase

	view: CHARACTER is 'v'
		-- Constant for 'view' selection

	view_u: CHARACTER is 'V'
		-- Constant for 'view' selection, uppercase

	sav: CHARACTER is 's'
		-- Constant for 'save' selection

	sav_u: CHARACTER is 'S'
		-- Constant for 'save' selection, uppercase

	previous: CHARACTER is '-'
		-- Constant for 'previous menu' selection

	shell_escape: CHARACTER is '!'
		-- Constant for 'shell escape' selection

end
