indexing
	description: "Enumerated 'command menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMAND_MENU_CHOICE inherit

	ENUMERATED [CHARACTER]

	COMMAND_MENU_VALUES

create

	make_description, make_edit, make_another, make_choice

create {ENUMERATED}

	make

feature -- Access

	value_set: LINKED_SET [CHARACTER] is
		once
			Result := value_set_implementation
		end

feature {NONE} -- Initialization

	make_description is
		do
			make ('d')
		end

	make_edit is
		do
			make ('e')
		end

	make_another is
		do
			make ('a')
		end

	make_choice is
		do
			make ('c')
		end

feature -- Access

invariant

end
