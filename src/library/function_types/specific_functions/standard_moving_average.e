indexing
	description:
	"Simple n-period moving average.  Can be specialized by descendants to %
	%provide different types of moving averages, such as exponential MA."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STANDARD_MOVING_AVERAGE inherit

	N_RECORD_ONE_VARIABLE_FUNCTION
		redefine
			set_operator, action, set_input, set_n, do_process, make,
			short_description
		select
			set_operator, set_input, set_n, make
		end

	N_RECORD_ONE_VARIABLE_FUNCTION
			-- Repeated inheritance is used to allow access to the
			-- parent set_xxx routines.
		rename
			set_n as nrovf_set_n, set_operator as nrovf_set_operator,
			set_input as nrovf_set_input, make as nrovf_make
		redefine
			action, do_process, short_description
		end

	COMMAND_EDITOR -- To allow editing of `sum'

creation {FACTORY}

	make

feature -- Access

	short_description: STRING is
		do
			!!Result.make (33)
			Result.append (n.out)
			Result.append ("-Period Simple Moving Average that operates %
							%on a data sequence")
		end

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

feature {NONE} -- Basic operations

	do_process is
			-- Sum the first n elements of target, then call continue_until
			-- to do the remaining work.
		local
			t: SIMPLE_TUPLE
		do
			check
				output_empty: output.empty
			end
			if target.count < n then
				-- null statement
			else
				check target.count >= n end
				target.start
				check target.index = 1 end
				sum.execute (Void)
				check
					target.index - 1 = n
				end
				-- The first trading period of the output is the nth trading
				-- period of the input (target).
				!!t.make (target.i_th (n).date_time, sum.value / n)
				last_sum := sum.value
				check
					target_index_correct: target.index = n + 1
				end
				-- sum.value = sum of first n elements of target.
				output.extend (t)
				continue_until
			end
		end

feature {FACTORY}

	set_input (in: MARKET_FUNCTION) is
		do
			Precursor (in)
			sum.set_target (in.output)
		end

	set_n (value: INTEGER) is
		do
			Precursor (value)
			check n = value end
			sum.initialize (Current)
		end

	set_operator (op: BASIC_NUMERIC_COMMAND) is
			-- operator will extract the appropriate field (close, high,
			-- open, etc.) from the market tuples being averaged, according
			-- to its type.
		do
			Precursor (op)
			sum.set_operand (op)
		ensure then
			sum_op_set: sum.operand = op and sum.operand /= Void
		end

feature {NONE}

	action is
			-- Default to simple moving average.
			-- Intended to be redefined by descenants for more complex MAs.
		local
			t: SIMPLE_TUPLE
			expired_value, latest_value: REAL
		do
			operator.execute (target.i_th (target.index - n))
			expired_value := operator.value
			operator.execute (target.item)
			latest_value := operator.value
			last_sum := last_sum - expired_value + latest_value
			!!t.make (target.item.date_time, last_sum / n)
			output.extend (t)
		ensure then
			one_more_in_output: output.count = old output.count + 1
			date_time_correspondence:
				output.last.date_time.is_equal (target.item.date_time)
		end

feature {NONE} -- Implementation

	sum: LINEAR_SUM
			-- Provides sum of first n elements.

	last_sum: REAL
			-- The last calculated sum

invariant

	sum_not_void: sum /= Void
	sum_attrs_equal_current_attrs: sum.n = n and sum.operand = operator

end -- class STANDARD_MOVING_AVERAGE
