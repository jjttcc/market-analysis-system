indexing
	description:
		"A numeric command that retrieves the value of the current item of %
		%a linear structure of market tuples"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_LINEAR_COMMAND inherit

	LINEAR_COMMAND

creation

	make

feature -- Initialization

	make (tgt: like target) is
		require
			not_void: tgt /= Void
		do
			target := tgt
		ensure
			target = tgt
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			value := target.item.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

	target_cursor_not_affected: BOOLEAN is true

end -- class BASIC_LINEAR_COMMAND
