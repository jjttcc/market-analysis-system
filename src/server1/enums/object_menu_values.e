indexing
	description: "Allowed values for an '<object> menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OBJECT_MENU_VALUES inherit

feature -- Access

	description: CHARACTER is 'd'
		-- Constant for 'description' selection

	description_u: CHARACTER is 'D'
		-- Constant for 'description' selection, uppercase

	choose: CHARACTER is 'c'
		-- Constant for 'choice' selection

	choose_u: CHARACTER is 'C'
		-- Constant for 'choice' selection, uppercase

	another_choice: CHARACTER is 'a'
		-- Constant for 'another choice' selection

	another_choice_u: CHARACTER is 'A'
		-- Constant for 'another choice' selection, uppercase

end
