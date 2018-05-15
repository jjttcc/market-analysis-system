note
	description:
		"Tradable function that accumulates values by, when calculating the %
		%current value for a period, using the previously calculated value"
	note1:
		"`previous_operator' has some special constraints - See note in %
		%parent, FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class ACCUMULATION inherit

	FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS
		rename
			set_operators as set_operators_unused
		export
			{NONE} set_operators_unused
		redefine
			operator, start, short_description 
		end

	COMMAND_EDITOR -- To allow editing of `previous_operator'

creation {FACTORY, TRADABLE_FUNCTION_EDITOR}

	make

feature -- Access

	short_description: STRING
		do
			create Result.make (33)
			Result.append ("Accumulation function that operates %
							%on a data sequence")
		end

	operator: BINARY_OPERATOR [DOUBLE, DOUBLE]
			-- Operator that performs the accumulation of the value for
			-- the current period with that for the previous period -
			-- usually will be ADDITION

feature {TRADABLE_FUNCTION_EDITOR} -- Status setting

	set_required_operators (op: like operator; pop: like previous_operator;
				fop: like first_element_operator)
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
				fop: like first_element_operator)
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

	start
		local
			t: SIMPLE_TUPLE
		do
			-- Operate on the first element of `target' (with
			-- `first_element_operator'), put the result into `output' as its
			-- first element, and increment `target' to the 2nd element.
			target.start
			if not target.is_empty then
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
			previous_operator.set (output)
			if debugging then
				print_status_report
			end
		ensure then
			empty_if_empty: target.is_empty = output.is_empty
			output_at_last: not output.is_empty implies output.islast
			output_one_less_than_target: not output.is_empty implies
				target.index = output.index + 1
		end

invariant

	prevop_not_void: previous_operator /= Void
	op_left_operand_is_prev_op: operator.operand1 = previous_operator

end -- class ACCUMULATION
