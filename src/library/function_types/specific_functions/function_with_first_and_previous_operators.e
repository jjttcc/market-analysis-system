note
	description:
		"One-variable function that adds a first-element operator and %
		%a 'previous' operator - to be used to construct complex functions %
		%such as accumulation functions and complex moving averages"
	note1:
		"`previous_operator' is used to retrieve the previously calculated %
		%value - that is, the last value placed into `output'.  Since the %
		%type of these values will be SIMPLE_TUPLE (which has a `value' %
		%feature but no open, high, low, volume, etc.), the type of the %
		%object that `previous_operator' is attached to must be one that %
		%doesn't try to access a feature, such as `open' that doesn't exist %
		%in SIMPLE_TUPLE."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS inherit

	ONE_VARIABLE_FUNCTION
		rename
			make as ovf_make
		export
			{NONE} set_operator
		redefine
			forth, direct_operators
		end

	COMMAND_EDITOR -- To allow editing of `previous_operator'

feature -- Access

	previous_operator: LINEAR_COMMAND
			-- Operator that operates on the previously calculated value

	first_element_operator: RESULT_COMMAND [DOUBLE]
			-- Operator that produces the first element of the output.

	direct_operators: LIST [COMMAND]
			-- All operators directly attached to Current
		do
			Result := Precursor
			if previous_operator /= Void then
				Result.extend (previous_operator)
			end
			Result.extend (first_element_operator)
		ensure then
			has_first_element_op: Result.has (first_element_operator)
			has_previous_operator_if_it_exists: previous_operator /= Void
				implies Result.has (previous_operator)
		end

feature {MARKET_FUNCTION_EDITOR} -- Status setting

	set_operators (op: like operator; pop: like previous_operator;
				fop: like first_element_operator)
			-- Set `operator' to `op' and `previous_operator' to `pop'.
		require
			op_fop_not_void: op /= Void and fop /= Void
		do
			operator := op
			previous_operator := pop
			first_element_operator := fop
		ensure
			operator_set: operator = op and operator /= Void
			previous_operator_set: previous_operator = pop
			first_element_operator_set: first_element_operator = fop and
				first_element_operator /= Void
		end

feature {NONE}

	forth
		do
			target.forth
			-- Ensure that output, used by previous_operator, is set to
			-- the item last inserted - the result of the last operation.
			output.forth
		ensure then
			output_at_last: output.islast
		end

invariant

	op_not_void: operator /= Void
	firstop_not_void: first_element_operator /= Void

end -- class FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS
