indexing
	description:
		"A numeric command that evaluates to a constant value"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CONSTANT inherit

	NUMERIC_COMMAND

creation

	make

feature

	make (r: REAL) is
		do
			value := r
		ensure
			set: rabs (value - r) < epsilon
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
		ensure then
			value = old value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

feature -- Status setting

	set_value (arg: REAL) is
			-- Set value to `arg'.
		require
			arg /= Void
		do
			value := arg
		ensure
			value_set: rabs (value - arg) < epsilon
		end

end -- class CONSTANT
