indexing
	description: "Exponential moving average";
	notes: "Formula taken from `Trading for a Living', by A. Elder"
	date: "$Date$";
	revision: "$Revision$"

class EXPONENTIAL_MOVING_AVERAGE inherit

	STANDARD_MOVING_AVERAGE
		redefine
			action, set_n
		end

creation

	make

feature -- Element change

	set_exponential (op: N_BASED_CALCULATION) is
		require
			op /= Void
		do
			exp := op
			exp.initialize (Current)
		ensure
			exp_set: exp = op and exp /= Void
		end

	set_n (i: integer) is
		do
			Precursor (i)
			if exp /= Void then
				exp.initialize (Current)
			end
		end

feature {NONE}

	action is
			-- Calculate exponential MA value for the current period.
		require else
			not output.empty
			target.index > n
		local
			t: SIMPLE_TUPLE
		do
			exp.execute (Current)
			!!t
			t.set_value (target.item.value * exp.value +
							output.last.value * (1 - exp.value))
			output.extend (t)
		ensure then
			-- output.last.value = P[curr] * exp + EMA[curr-1] * (1 - exp)
			--   where P[curr] is the price for the current period and
			--   EMA[curr-1] is the EMA for the previous period.
		end

feature {NONE}

	exp: N_BASED_CALCULATION
			-- The so-called exponential

end -- class EXPONENTIAL_MOVING_AVERAGE
