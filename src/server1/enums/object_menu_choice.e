indexing
	description: "Enumerated '<object> menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OBJECT_MENU_CHOICE inherit

	ENUMERATED [CHARACTER]

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

	make_another is
		do
			make ('a')
		end

	make_choice is
		do
			make ('c')
		end

end
