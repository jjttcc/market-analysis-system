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
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ACCUMULATION inherit

	ONE_VARIABLE_FUNCTION
		rename
			make as ovf_make_not_used
		redefine
			operator, action, forth, start, short_description
		end

	COMMAND_EDITOR -- To allow editing of `previous_operator'

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Access

	short_description: STRING is
		do
			!!Result.make (33)
			Result.append ("Accumulation function that operates %
							%on a data sequence")
		end

	operator: BINARY_OPERATOR [REAL, REAL]
			-- Operator that performs the accumulation of the value for
			-- the current period with that for the previous period -
			-- usually will be ADDITION

	previous_operator: LINEAR_COMMAND

feature {NONE} -- Initialization

	make (in: like input; op: like operator;
			prev_op: like previous_operator) is
		require
			op_left_operand_is_prev_op: op.operand1 = prev_op
		do
			check operator_used end
			!!output.make (in.output.count) --??
			previous_operator := prev_op
		end

feature {NONE}

	start is
		local
			t: SIMPLE_TUPLE
		do
			-- Operate on the first element of `target' (with
			-- `previous_operator'), put the result into `output' as its
			-- first element, and increment `target' to the 2nd element.
			target.start
			previous_operator.set_target (target)
			previous_operator.execute (Void)
			!!t.make (target.item.date_time, target.item.end_date,
						previous_operator.value)
			output.extend (t)
			-- Prepare output for use by previous_operator - set to
			-- first item that was inserted above.
			output.start
			previous_operator.set_target (output)
			target.forth
		ensure then
			output_at_last: output.islast
			output_one_less_than_target: target.index = output.index + 1
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

	action is
		local
			t: SIMPLE_TUPLE
		do
			check
				output.islast
			end
			-- `operator' (a binary operator) will first execute its left
			-- operand (previous_operator), which will retrieve (and possibly
			-- change) the current (last) item of `output'.  Then `operator'
			-- will execute its right operand and operate on these two
			-- results.
			operator.execute (target.item)
			!!t.make (target.item.date_time, target.item.end_date,
						operator.value)
			output.extend (t)
		ensure then
			output.count = old output.count + 1
		end

invariant

	ops_not_void: operator /= Void and previous_operator /= Void
	op_left_operand_is_prev_op: operator.operand1 = previous_operator

end -- class ACCUMULATION
