indexing
	description: "Enumerated 'command menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMAND_MENU_CHOICE inherit

	OBJECT_MENU_CHOICE

	COMMAND_MENU_VALUES
		undefine
			out
		end

create

	make_description, make_edit, make_another, make_choice

create {ENUMERATED}

	make

feature {NONE} -- Initialization

	make_edit is
		do
			make ('e')
		end

end
