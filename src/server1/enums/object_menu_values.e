indexing
	description: "Allowed values for an '<object> menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
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

	object_name: STRING is
		deferred
		end

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER] is
		do
io.error.print ("initial_allowable_values called for OMV%N")
			Result := <<description, description_u, choose, choose_u,
				another_choice, another_choice_u>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER] is
		do
			create Result.make (6)
			Result.put ("description of the " + object_name, description)
			Result.put ("description of the " + object_name, description_u)
			Result.put ("Choose a " + object_name, choose)
			Result.put ("Choose a " + object_name, choose_u)
			Result.put ("Choose another " + object_name, another_choice)
			Result.put ("Choose another " + object_name, another_choice_u)
		end

invariant

	name_exists: object_name /= Void and then not object_name.is_empty
	implementation_data_exist: value_name_map /= Void

end
