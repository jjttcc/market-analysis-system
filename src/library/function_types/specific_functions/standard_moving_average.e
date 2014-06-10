note
	description:
	"Simple n-period moving average.  Can be specialized by descendants to %
	%provide different types of moving averages, such as exponential MA."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class STANDARD_MOVING_AVERAGE inherit

	N_RECORD_ONE_VARIABLE_FUNCTION
		redefine
			set_operator, action, set_input, set_n, do_process, make,
			short_description, direct_operators
		select
			set_operator, set_input, set_n, make
		end

	N_RECORD_ONE_VARIABLE_FUNCTION
			-- Repeated inheritance is used to allow access to the
			-- parent set_xxx routines.
		rename
			set_n as nrovf_set_n, set_operator as nrovf_set_operator,
			set_input as nrovf_set_input, make as nrovf_make
		undefine
			direct_operators
		redefine
			action, do_process, short_description
		end

	COMMAND_EDITOR -- To allow editing of `sum'

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Access

	short_description: STRING
		do
			create Result.make (33)
			Result.append (n.out)
			Result.append ("-Period Simple Moving Average that operates %
							%on a data sequence")
		end

	direct_operators: LIST [COMMAND]
			-- All operators directly attached to Current
		do
			Result := Precursor
			Result.extend (sum)
		ensure then
			has_sum: Result.has (sum)
		end

feature {NONE} -- Initialization

	make (in: like input; op: like operator; i: INTEGER)
		do
			check operator_used end
			create sum.make (in.output, op, i)
			create output.make (in.output.count)
			nrovf_set_input (in)
			nrovf_set_operator (op)
			nrovf_set_n (i)
		end

feature {NONE} -- Basic operations

	do_process
			-- Sum the first n elements of target, then call continue_until
			-- to do the remaining work.
		local
			t: SIMPLE_TUPLE
		do
			check
				output_empty: output.is_empty
			end
			if target.count < effective_n then
				-- null statement
			else
				check target.count >= effective_n end
				from target.start until
					target.index - 1 = effective_offset
				loop target.forth end
				check target.index = effective_offset + 1 end
				sum.execute (Void)
				check
					target_cursor_advanced: target.index - 1 = effective_n
				end
				-- The first trading period of the output is the nth trading
				-- period of the input (target).
				create t.make (target.i_th (effective_n).date_time,
							target.i_th (effective_n).end_date, sum.value / n)
				last_sum := sum.value
				check
					target_index_correct: target.index = effective_n + 1
				end
				-- sum.value = sum applied to
				--   target[effective_offset+1 .. effective_n]
				output.extend (t)
				if debugging then
					print_status_report
				end
				continue_until
			end
		end

feature {MARKET_FUNCTION_EDITOR}

	set_input (in: MARKET_FUNCTION)
		do
			Precursor (in)
			sum.set (in.output)
		end

	set_n (value: INTEGER)
		do
			Precursor (value)
			check n = value end
			sum.initialize (Current)
		end

	set_operator (op: like operator)
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

	action
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
			create t.make (target.item.date_time, target.item.end_date,
						last_sum / n)
			output.extend (t)
			if debugging then
				print_status_report
			end
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
