indexing
	description:
	"Simple n-period moving average.  Can be specialized by descendants to %
	%provide different types of moving averages, such as exponential MA."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class STANDARD_MOVING_AVERAGE inherit

	N_RECORD_ONE_VARIABLE_FUNCTION
		redefine
			set_operator, action, set_input, set_n, do_process, make,
			short_description, operators
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
			operators
		redefine
			action, do_process, short_description
		end

	COMMAND_EDITOR -- To allow editing of `sum'

GENERAL_UTILITIES
--!!!cleanup.

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Access

	short_description: STRING is
		do
			create Result.make (33)
			Result.append (n.out)
			Result.append ("-Period Simple Moving Average that operates %
							%on a data sequence")
		end

	operators: LIST [COMMAND] is
		do
			Result := Precursor
			Result.append (operator_and_descendants (sum))
		end

feature {NONE} -- Initialization

	make (in: like input; op: like operator; i: INTEGER) is
		do
			check operator_used end
			create sum.make (in.output, op, i)
			create output.make (in.output.count)
			nrovf_set_input (in)
			nrovf_set_operator (op)
			nrovf_set_n (i)
		end

feature {NONE} -- Basic operations

	out_index: INTEGER
			-- Current array index for `output'

	resize_output (sz: INTEGER) is
		do
			if output.count /= sz then
				output.make_filled (sz)
			end
		ensure
			resized: output.count = sz
		end

	do_process is
			-- Sum the first n elements of target, then call continue_until
			-- to do the remaining work.
		local
			t: SIMPLE_TUPLE
		do
			if target.count < effective_n then
				out_index := 0
			else
				check target.count >= effective_n end
				target.go_i_th (effective_offset + 1)
				check target.index = effective_offset + 1 end
				sum.execute (Void)
				check
					target.index - 1 = effective_n
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
				resize_output (target.count - effective_n + 1)
				out_index := 1
				check
					out_index_valid: output.count > out_index
				end
				output.put_i_th (t, out_index)
				finish_processing (target, output)
			end
		end

	finish_processing (t, o: ARRAYED_LIST [MARKET_TUPLE]) is
		local
			tcount, ocount: INTEGER
			st: SIMPLE_TUPLE
		do
			from
				ocount := o.count
				tcount := t.count
			until
				t.index > tcount
			loop
				st := current_result (t, o, out_index)
				out_index := out_index + 1
				if not (out_index > ocount) then
					o.put_i_th (st, out_index)
				else
print_list (<<"Calling o.extend at oidx ", out_index, ".%N">>)
					o.extend (st)
					ocount := o.count
				end
				t.forth
			end
		end

	old_do_process is
			-- Sum the first n elements of target, then call continue_until
			-- to do the remaining work.
		local
			t: SIMPLE_TUPLE
		do
			check
				output_empty: output.empty
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
					target.index - 1 = effective_n
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
				continue_until
			end
		end

feature {MARKET_FUNCTION_EDITOR}

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

	set_operator (op: like operator) is
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

	current_result (t, o: ARRAYED_LIST [MARKET_TUPLE]; last_oindex: INTEGER):
		SIMPLE_TUPLE is
			-- Tuple produced from the current item of `t'
			-- Default to simple moving average.
			-- Intended to be redefined by descenants for more complex MAs.
			-- `o' is a reference to the `output' attribute (for efficiency)
			-- and `last_oindex' is the last valid index of `o'.
		local
			expired_value, latest_value: REAL
		do
			operator.execute (t.i_th (t.index - n))
			expired_value := operator.value
			operator.execute (t.item)
			latest_value := operator.value
			last_sum := last_sum - expired_value + latest_value
			create Result.make (t.item.date_time, t.item.end_date,
						last_sum / n)
		ensure then
			date_time_correspondence:
				Result.date_time.is_equal (t.item.date_time)
		end

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
			create t.make (target.item.date_time, target.item.end_date,
						last_sum / n)
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
