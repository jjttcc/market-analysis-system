indexing
	description: "Allowed values for a 'command menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMAND_MENU_VALUES inherit

feature -- Access

	description: CHARACTER is 'd'

	description_upper: CHARACTER is 'D'

	choose: CHARACTER is 'c'

	choose_upper: CHARACTER is 'C'

	edit: CHARACTER is 'e'

	edit_upper: CHARACTER is 'E'

	another_choice: CHARACTER is 'a'

	another_choice_upper: CHARACTER is 'A'

feature {NONE} -- Implementation

	allowable_values: ARRAY [CHARACTER] is
		once
			Result := <<description, description_upper, choose, choose_upper,
				edit, edit_upper, another_choice, another_choice_upper>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER] is
		do
			create Result.make (8)
			Result.put ("description of the command", description)
			Result.put ("description of the command", description_upper)
			Result.put ("Choose a command", choose)
			Result.put ("Choose a command", choose_upper)
			Result.put ("Edit a command", edit)
			Result.put ("Edit a command", edit_upper)
			Result.put ("Choose another command", another_choice)
			Result.put ("Choose another command", another_choice_upper)
		end

invariant

end
