indexing
	description: "Enumerated 'market-function menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class FUNCTION_MENU_CHOICE inherit

	OBJECT_MENU_CHOICE

	FUNCTION_MENU_VALUES
		undefine
			out
		end

create

	make_description, make_another, make_choice

create {ENUMERATED}

	make

feature -- Access

	new_instance (value: CHARACTER): FUNCTION_MENU_CHOICE is
		do
			create Result.make (value)
		end

end
