note
	description: "Enumerated '<object> menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class OBJECT_MENU_CHOICE inherit

	CHARACTER_ENUMERATED

	OBJECT_MENU_VALUES
		undefine
			out
		end

feature -- Access

feature {NONE} -- Initialization

	make_description
		do
			make ('d')
		end

	make_another
		do
			make ('a')
		end

	make_choice
		do
			make ('c')
		end

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER]
		do
			Result := <<description, description_u, choose, choose_u,
				another_choice, another_choice_u>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER]
		do
			create Result.make (6)
			Result.put ("Description of the " + type_name, description)
			Result.put ("Description of the " + type_name, description_u)
			Result.put ("Choose a " + type_name, choose)
			Result.put ("Choose a " + type_name, choose_u)
			Result.put ("Choose another " + type_name, another_choice)
			Result.put ("Choose another " + type_name, another_choice_u)
		end

invariant

end
