indexing
	description:
		"A numeric command that evaluates to a constant value"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class CONSTANT inherit

	NUMERIC_COMMAND
		rename
			value as constant_value
		end

creation

	make

feature

	make (r: REAL) is
		do
			constant_value := r
		ensure
			set: rabs (constant_value - r) < epsilon
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
		ensure then
			constant_value = old constant_value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

feature -- Status setting

	set_constant_value (arg: REAL) is
			-- Set constant_value to `arg'.
		require
			arg /= Void
		do
			constant_value := arg
		ensure
			constant_value_set: rabs (constant_value - arg) < epsilon
		end

end -- class CONSTANT
