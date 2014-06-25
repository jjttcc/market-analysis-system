note
	description: "Enumerated '<object> editing' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class OBJECT_EDITING_CHOICE inherit

	CHARACTER_ENUMERATED

	OBJECT_EDITING_VALUES
		undefine
			out
		end

feature {NONE} -- Initialization

	make_creat
		do
			make ('c')
		end

	make_remove
		do
			make ('r')
		end

	make_edit
		do
			make ('e')
		end

	make_view
		do
			make ('v')
		end

	make_save
		do
			make ('s')
		end

	make_previous
		do
			make ('-')
		end

	make_shell_escape
		do
			make ('!')
		end

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER]
		do
			Result := <<creat, creat_u, remove, remove_u, edit, edit_u,
				view, view_u, sav, sav_u, previous, shell_escape>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER]
		do
			create Result.make (11)
			Result.put ("Create a new " + type_name, creat)
			Result.put ("Create a new " + type_name, creat_u)
			Result.put ("Remove an " + type_name, remove)
			Result.put ("Remove an " + type_name, remove_u)
			Result.put ("Edit an " + type_name, edit)
			Result.put ("Edit an " + type_name, edit_u)
			Result.put ("View an " + type_name, view)
			Result.put ("View an " + type_name, view_u)
			Result.put ("Save changes", sav)
			Result.put ("Save changes", sav_u)
			Result.put ("Previous", previous)
			Result.put ("Start shell", shell_escape)
		end

invariant

end
