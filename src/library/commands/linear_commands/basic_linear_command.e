indexing
	description:
		"A numeric command that operates on a linear structure without %
		%changing its cursor position"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_LINEAR_COMMAND inherit

	LINEAR_COMMAND

creation

	make

feature -- Basic operations

	execute (arg: ANY) is
				-- Default: set value to current item - can be redefined
				-- by ancestors.
		do
			value := target.item.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

	target_cursor_not_affected: BOOLEAN is true

end -- class BASIC_LINEAR_COMMAND
