note
	description: "Allowed values for an '<object> menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OBJECT_MENU_VALUES inherit

feature -- Access

	description: CHARACTER = 'd'
		-- Constant for 'description' selection

	description_u: CHARACTER = 'D'
		-- Constant for 'description' selection, uppercase

	choose: CHARACTER = 'c'
		-- Constant for 'choice' selection

	choose_u: CHARACTER = 'C'
		-- Constant for 'choice' selection, uppercase

	another_choice: CHARACTER = 'a'
		-- Constant for 'another choice' selection

	another_choice_u: CHARACTER = 'A'
		-- Constant for 'another choice' selection, uppercase

end
