indexing
	description: "Allowed values for a 'function menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class FUNCTION_MENU_VALUES inherit

feature -- Access

	description: CHARACTER is 'd'

	description_upper: CHARACTER is 'D'

	choose: CHARACTER is 'c'

	choose_upper: CHARACTER is 'C'

	another_choice: CHARACTER is 'a'

	another_choice_upper: CHARACTER is 'A'

	object_name: STRING is "function"

feature {NONE} -- Implementation

	allowable_values: ARRAY [CHARACTER] is
		once
			Result := <<description, description_upper, choose, choose_upper,
				another_choice, another_choice_upper>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER] is
		do
			create Result.make (8)
			Result.put ("description of the " + object_name, description)
			Result.put ("description of the " + object_name, description_upper)
			Result.put ("Choose a " + object_name, choose)
			Result.put ("Choose a " + object_name, choose_upper)
			Result.put ("Choose another " + object_name, another_choice)
			Result.put ("Choose another " + object_name, another_choice_upper)
		end

invariant

end
