indexing
	description: "Enumerated '<object> editing' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OBJECT_EDITING_CHOICE inherit

	ENUMERATED [CHARACTER]

	OBJECT_EDITING_VALUES
		undefine
			out
		end

feature -- Access

	object_name: STRING is
		deferred
		end

	item_description: STRING is
			-- Description of the editing choice 'item'
		do
			Result := value_name_map @ item
		end

feature {NONE} -- Initialization

	make_creat is
		do
			make ('c')
		end

	make_remove is
		do
			make ('r')
		end

	make_edit is
		do
			make ('e')
		end

	make_view is
		do
			make ('v')
		end

	make_save is
		do
			make ('s')
		end

	make_previous is
		do
			make ('-')
		end

	make_shell_escape is
		do
			make ('!')
		end

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER] is
		do
			Result := <<creat, creat_u, remove, remove_u, edit, edit_u,
				view, view_u, sav, sav_u, previous, shell_escape>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER] is
		do
			create Result.make (11)
			Result.put ("Create a new " + object_name, creat)
			Result.put ("Create a new " + object_name, creat_u)
			Result.put ("Remove an " + object_name, remove)
			Result.put ("Remove an " + object_name, remove_u)
			Result.put ("Edit an " + object_name, edit)
			Result.put ("Edit an " + object_name, edit_u)
			Result.put ("View an " + object_name, view)
			Result.put ("View an " + object_name, view_u)
			Result.put ("Save changes", sav)
			Result.put ("Save changes", sav_u)
			Result.put ("Previous", previous)
			Result.put ("Start shell", shell_escape)
		end

invariant

	name_exists: object_name /= Void and then not object_name.is_empty
	implementation_data_exist: value_name_map /= Void

end
