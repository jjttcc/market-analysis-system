indexing
	description:
		"A numeric command that evaluates to a constant value"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
