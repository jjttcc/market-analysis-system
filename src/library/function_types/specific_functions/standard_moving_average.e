indexing
	description:
	"Basic structure for some of the more common moving averages, such as %
	%simple moving average and exponential moving average.  Based on the %
	%convention of summing the first n elements of the input, using that %
	%result for the first output element, and calculating the remaining %
	%output elements by redefining action, which is used in the iteration %
	%machine.";
	date: "$Date$";
	revision: "$Revision$"

class STANDARD_MOVING_AVERAGE inherit

	N_RECORD_ONE_VARIABLE_FUNCTION
		redefine
			set_operator, action, set_input, set_n, do_process, make
		select
		--	set_operator, action, set_input, set_n, do_process
			set_operator, set_input, set_n, make
		end

	N_RECORD_ONE_VARIABLE_FUNCTION
		rename
			set_n as nrovf_set_n, set_operator as nrovf_set_operator,
			set_input as nrovf_set_input, make as nrovf_make
		redefine
			action, do_process
		end

creation {FACTORY}

	make

feature {NONE} -- Initialization

	make (in: like input; op: BASIC_NUMERIC_COMMAND; i: INTEGER) is
		do
			check operator_used end
			!!sum.make (in.output, op, i)
			!!output.make (in.output.count)
			nrovf_set_input (in)
			nrovf_set_operator (op)
			nrovf_set_n (i)
		end

feature -- Basic operations

	do_process is
		local
			t: SIMPLE_TUPLE
		do
			target.start
			check target.index = 1 end
			sum.execute (Void)
			check
				target.index - 1 = n
				-- (or target.exhausted)!
			end
			!!t
			t.set_value (sum.value / (target.index - 1))
			-- The first trading period of the output is the nth trading
			-- period of the input (target).
			t.set_date_time (target.i_th (target.index - 1).date_time)
			last_sum := sum.value
			-- sum.value = sum of the first target.index-1 elements of target.
			output.extend (t)
			continue_until
		end

feature {FACTORY}

	set_input (in: MARKET_FUNCTION) is
		do
			Precursor (in)
			sum.set_target (in.output)
		end

	set_n (v: INTEGER) is
		do
			Precursor (v)
			check n = v end
			sum.set_n (n)
		end

	set_operator (op: BASIC_NUMERIC_COMMAND) is
			-- operator will extract the appropriate field (close, high,
			-- open, etc.) from the market tuples being averaged, according
			-- to its type.
		do
			Precursor (op)
			sum.set_operator (op)
		ensure then
			sum_op_set: sum.operator = op and sum.operator /= Void
		end

feature {NONE}

	action is
			-- Default to simple moving average.
			-- Intended to be redefined by descenants for more complex MAs.
		local
			t: SIMPLE_TUPLE
		do
			--!!!Bug:  instead of using target.(expr).value directly,
			--!!!should be using operator.  A local double variable
			--!!!will need to be used.
			!!t
			last_sum := last_sum - target.i_th(target.index - n).value +
							target.item.value
			t.set_value (last_sum / n)
			t.set_date_time (target.item.date_time)
			output.extend (t)
		end

feature {NONE} -- Implementation

	sum: LINEAR_SUM
			-- Provides sum of first n elements.

	last_sum: REAL
			-- The last calculated sum

invariant

	sum_not_void: sum /= Void
	sum_attrs_equal_current_attrs: sum.n = n and sum.operator = operator

end -- class STANDARD_MOVING_AVERAGE
