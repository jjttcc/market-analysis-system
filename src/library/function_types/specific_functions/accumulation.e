indexing
	description:
		"Market function that accumulates values by, when calculating the %
		%current value for a period, using the previously calculated value"
	note:
		"`previous_operator' is used to retrieve the previously calculated %
		%value.  Since the type of these values will be SIMPLE_TUPLE (which %
		%has a `value' feature but no open, high, low, volume, etc.), the %
		%type of the object that `previous_operator' is attached to must %
		%be one that doesn't try to access a feature, such as `open' that %
		%doesn't exist in SIMPLE_TUPLE."
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ACCUMULATION inherit

	ONE_VARIABLE_FUNCTION
		rename
			make as ovf_make
		export
			{NONE} set_operator
		redefine
			operator, forth, start, short_description
		end

	COMMAND_EDITOR -- To allow editing of `previous_operator'

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Access

	short_description: STRING is
		do
			create Result.make (33)
			Result.append ("Accumulation function that operates %
							%on a data sequence")
		end

	operator: BINARY_OPERATOR [REAL, REAL]
			-- Operator that performs the accumulation of the value for
			-- the current period with that for the previous period -
			-- usually will be ADDITION

	previous_operator: LINEAR_COMMAND
			-- Operator that Operates on the previously calculated value

	first_element_operator: RESULT_COMMAND [REAL]
			-- Operator that operates only on the first element of the input.

feature {MARKET_FUNCTION_EDITOR} -- Status setting

	set_operators (op: like operator; pop: like previous_operator;
				fop: like first_element_operator) is
			-- Set `operator' to `op' and `previous_operator' to `pop'.
		require
			not_void: op /= Void and pop /= Void and fop /= Void
			left_operand_is_pop: op.operand1 = pop
		do
			operator := op
			previous_operator := pop
			first_element_operator := fop
		ensure
			operator_set: operator = op and operator /= Void
			previous_operator_set: previous_operator = pop and
				previous_operator /= Void
			first_element_operator_set: first_element_operator = fop and
				first_element_operator /= Void
		end

feature {NONE} -- Initialization

	make (in: like input; op: like operator; prev_op: like previous_operator;
				fop: like first_element_operator) is
		require
			not_void: in /= Void and op /= Void and prev_op /= Void and
				fop /= Void
			left_operand_is_prev_op: op.operand1 = prev_op
			in_ptype_not_void: in.trading_period_type /= Void
		do
			check operator_used end
			ovf_make (in, op)
			previous_operator := prev_op
			first_element_operator := fop
		ensure then
			prev_op_is_op_left_op: previous_operator = op.operand1
			ops_set: operator = op and previous_operator = prev_op and
				first_element_operator = fop
			input_set: input = in
		end

feature {NONE}

	start is
		local
			t: SIMPLE_TUPLE
		do
			-- Operate on the first element of `target' (with
			-- `first_element_operator'), put the result into `output' as its
			-- first element, and increment `target' to the 2nd element.
			target.start
			if not target.empty then
				first_element_operator.execute (target.item)
				create t.make (target.item.date_time, target.item.end_date,
							first_element_operator.value)
				output.extend (t)
				target.forth
			end
			-- Prepare output for use by previous_operator - set to first
			-- item that was inserted above or `after' if target is empty.
			output.start
			-- Important - previous operator will operate on the current
			-- item of `output', which will always be the last inserted item.
			previous_operator.set_target (output)
		ensure then
			empty_if_empty: target.empty = output.empty
			output_at_last: not output.empty implies output.islast
			output_one_less_than_target: not output.empty implies
				target.index = output.index + 1
		end

	forth is
		do
			target.forth
			-- Ensure that output, used by previous_operator, is set to
			-- the item last inserted - the result of the last operation.
			output.forth
		ensure then
			output_at_last: output.islast
			output_one_less_than_target: target.index = output.index + 1
		end

invariant

	ops_not_void: operator /= Void and previous_operator /= Void
	op_left_operand_is_prev_op: operator.operand1 = previous_operator

end -- class ACCUMULATION
