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
			set_operator, action, set_input, set_n, do_process
		end

creation

	make

feature -- Basic operations

	do_process is
		local
			old_index: INTEGER
			t: SIMPLE_TUPLE
		do
			target.start
			old_index := target.index
			sum.execute (Void)
			check target.index = old_index + n end
			!!t
			t.set_value (sum.value / n)
			-- The first trading period of the output is the nth trading
			-- period of the input (target).
			t.set_date_time (target.i_th (target.index - 1).date_time)
			last_sum := sum.value
			-- value holds the sum of the first n elements of target
			output.extend (t)
			continue_until
		end

feature {FACTORY}

	set_input (in: MARKET_FUNCTION) is
		do
			sum.set_target (in.output)
			Precursor (in)
		end

	set_n (v: INTEGER) is
		do
			Precursor (v)
			check n = v end
			sum.initialize (Current)
		end

	set_operator (op: BASIC_NUMERIC_COMMAND) is
		do
			Precursor (op)
			sum.set_operator (op)
		ensure then
			op_set: sum.operator = op and sum.operator /= Void
		end

feature {NONE}

	action is
			-- Default to simple moving average.
			-- Intended to be redefined by descenants for more complex MAs.
		local
			t: SIMPLE_TUPLE
		do
			!!t
			last_sum := last_sum - target.i_th(target.index - n).value +
							target.item.value
			t.set_value (last_sum / n)
			t.set_date_time (target.item.date_time)
			output.extend (t)
		end

feature {NONE} -- Implementation

	sum: expanded LINEAR_SUM
			-- Provides sum of first n elements.

	last_sum: REAL
			-- The last calculated sum

end -- class STANDARD_MOVING_AVERAGE
