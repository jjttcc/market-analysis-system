indexing
	description: "Allowed values for a 'command menu' selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMAND_MENU_VALUES inherit

	OBJECT_MENU_VALUES
		redefine
			initial_allowable_values, value_name_map
		end

feature -- Access

	edit: CHARACTER is 'e'
		-- Constant for 'edit' selection

	edit_u: CHARACTER is 'E'
		-- Constant for 'edit' selection, uppercase

	object_name: STRING is "command"

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER] is
		do
io.error.print ("initial_allowable_values called for CMV%N")
			Result := Precursor
			Result.force (edit, Result.upper + 1)
			Result.force (edit_u, Result.upper + 1)
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER] is
		do
			Result := Precursor
			Result.put ("Edit a " + object_name, edit)
			Result.put ("Edit a " + object_name, edit_u)
		end

invariant

end
