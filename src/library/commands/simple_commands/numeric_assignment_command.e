indexing
	description: "Commands that provide an assignment instruction by %
		%executing a `main_operator' and storing the resulting numeric %
		%value in a `target'.  The result (`value') is then `target.value'."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class NUMERIC_ASSIGNMENT_COMMAND inherit

	UNARY_OPERATOR [REAL, REAL]
		rename
			operand as main_operator
		redefine
			operate, children
		end

	MATH_CONSTANTS
		export
			{NONE} all
		end

create

	make

feature -- Initialization

	make (main_op: RESULT_COMMAND [REAL]; target_op: NUMERIC_VALUE_COMMAND) is
		require
			args_exist: main_op /= Void and target_op /= Void
		do
			main_operator := main_op
			target := target_op
			-- main_operator is not a valid function parameter:
			target.set_is_editable (False)
		ensure
			operators_set: main_operator = main_op and
				target = target_op
		end

feature -- Access

	target: NUMERIC_VALUE_COMMAND
			-- The "target" object - updated with the last calculated value.

	children: LIST [COMMAND] is
		do
			Result := Precursor
			Result.extend (target)
		end

feature -- Element change

	set_target (arg: NUMERIC_VALUE_COMMAND) is
			-- Set `target' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			target := arg
		ensure
			target_set: target = arg and target /= Void
		end

feature -- Basic operations

	operate (v: REAL) is
		do
			value := v
			target.set_value (value)
		ensure then
			value_is_target_value:
				reals_equal (value, target.value)
		end

invariant

	operators_exist: target /= Void

end
