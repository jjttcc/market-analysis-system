indexing
	description: "Exponential moving average";
	notes: "Formula taken from `Trading for a Living', by A. Elder"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class EXPONENTIAL_MOVING_AVERAGE inherit

	STANDARD_MOVING_AVERAGE
		rename
			make as sma_make
		redefine
			action, set_n, short_description
		end

creation {FACTORY}

	make

feature -- Access

	short_description: STRING is
		do
			!!Result.make (38)
			Result.append (n.out)
			Result.append ("-Period Exponential Moving Average that operates %
							%on a data sequence")
		end

feature {NONE} -- Initialization

	make (in: like input; op: BASIC_NUMERIC_COMMAND; e: N_BASED_CALCULATION;
			i: INTEGER) is
		require
			args_not_void: in /= Void and e /= Void and op /= Void
			i_gt_0: i > 0
		do
			check operator_used end
			sma_make (in, op, i)
			check n = i end
			set_exponential (e)
		ensure
			set: input = in and operator = op and n = i
			e_n_set_to_i: e.n = i
			exp_set: exp = e
			target_set: target = in.output
		end

feature {FACTORY} -- Status setting

	set_exponential (e: N_BASED_CALCULATION) is
		require
			e /= Void
		do
			exp := e
			exp.set_n (n)
		ensure
			exp_set: exp = e and exp /= Void
		end

	set_n (value: integer) is
		do
			Precursor (value)
			exp.set_n (n)
		end

feature {NONE}

	action is
			-- Calculate exponential MA value for the current period.
		require else
			output_not_empty: not output.empty
			tgindex_gt_n: target.index > n
		local
			t: SIMPLE_TUPLE
			latest_value: REAL
		do
			exp.execute (Void)
			!!t
			operator.execute (target.item)
			latest_value := operator.value
			t.set_value (latest_value * exp.value +
							output.last.value * (1 - exp.value))
			t.set_date_time (target.item.date_time)
			output.extend (t)
		ensure then
			-- output.last.value = P[curr] * exp + EMA[curr-1] * (1 - exp)
			--   where P[curr] is the price for the current period and
			--   EMA[curr-1] is the EMA for the previous period.
		end

feature {NONE}

	exp: N_BASED_CALCULATION
			-- The so-called exponential

invariant

	exp_not_void: exp /= Void
	n_equals_exp_n: n = exp.n

end -- class EXPONENTIAL_MOVING_AVERAGE
