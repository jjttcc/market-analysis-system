indexing
	description: "Commands that execute a `main_operator' and store the %
		%resulting value in a `managed_value'.  The result (`value') %
		%is then `managed_value.value'."
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MANAGED_VALUE_COMMAND inherit

	UNARY_OPERATOR [REAL, REAL]
		rename
			operand as main_operator
		redefine
			operate
		end

	MATH_CONSTANTS
		export
			{NONE} all
		end

create

	make

feature -- Initialization

	make (main_op: RESULT_COMMAND [REAL]; managed_op: CONSTANT) is
		require
			args_exist: main_op /= Void and managed_op /= Void
		do
			main_operator := main_op
			managed_value := managed_op
			-- main_operator is not a valid function parameter:
			managed_value.set_is_editable (False)
		ensure
			operators_set: main_operator = main_op and
				managed_value = managed_op
		end

feature -- Access

	managed_value: CONSTANT
			-- The "managed" object - updated with the last calculated value.

feature -- Element change

	set_managed_value (arg: CONSTANT) is
			-- Set `managed_value' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			managed_value := arg
		ensure
			managed_value_set: managed_value = arg and managed_value /= Void
		end

feature -- Basic operations

	operate (v: REAL) is
		do
			value := v
			managed_value.set_value (value)
		ensure then
			value_is_managed_value_value:
				reals_equal (value, managed_value.value)
		end

invariant

	operators_exist: main_operator /= Void and managed_value /= Void

end
