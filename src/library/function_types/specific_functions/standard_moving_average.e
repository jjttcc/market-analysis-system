indexing
	description: "Basic structure for some of the more common moving%
				%averages, such as simple moving average and exponential%
				%moving average.  Based on the convention of summing the%
				%first n elements of the input, using that result for the%
				%first output element, and calculating the remaining%
				%output elements by redefining action, which is used in%
				%the iteration machine.";
	date: "$Date$";
	revision: "$Revision$"

class STANDARD_MOVING_AVERAGE inherit

	MARKET_FUNCTION
		export {NONE}
			set_operator
		redefine
			output
		end

	VECTOR_ANALYZER
		redefine
			action, reset_state, set_input
		end

	N_RECORD_STRUCTURE
		redefine
			set_n
		end

creation

	make

feature -- Basic operations

	process is
		local
			old_index: INTEGER
			t: SIMPLE_TUPLE
		do
			input.start
			old_index := input.index
			sum.execute (Void)
			check input.index = old_index + n end
			!!t
			t.set_value (sum.value / n)
			last_sum := sum.value
			-- value holds the sum of the first n elements of input
			output.extend (t)
			continue_until
			processed := true
		end

feature

	set_input (the_input: ARRAYED_LIST [MARKET_TUPLE]) is
		do
			sum.set_input (the_input)
			Precursor (the_input)
		end

	set_n (v: INTEGER) is
		do
			sum.set_n (v)
			Precursor (v)
		end

feature

	output: ARRAYED_LIST [SIMPLE_TUPLE]

feature {NONE}

	action is
			-- Default to simple moving average.
			-- Intended to be redefined by descenants for more complex MAs.
		local
			t: SIMPLE_TUPLE
		do
			!!t
			last_sum := last_sum - input.i_th(input.index - n).value +
							input.item.value
			t.set_value (last_sum / n)
			output.extend (t)
		end

	reset_state is
			-- Reset to initial state.
			-- Intended to be redefined as needed.
		do
			processed := false
		end

feature {NONE} -- Implementation

	sum: expanded VECTOR_SUM
			-- Provides sum of first n elements.

	last_sum: REAL
			-- The last calculated sum

end -- class STANDARD_MOVING_AVERAGE
