indexing
	description: "A single-value tuple."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class SIMPLE_TUPLE inherit

	MARKET_TUPLE
		redefine
			end_date
		end

creation

	make

feature -- Initialization

	make (d: DATE_TIME; end_dt: DATE; v: REAL) is
		do
			date_time := d
			value := v
			end_date := end_dt
		ensure
			dates_set: date_time = d and end_date = end_dt
			-- value_set: rabs (value - v) < epsilon
		end

feature -- Access

	value: REAL

	end_date: DATE

feature {MARKET_FUNCTION} -- Status setting

	set_value (v: REAL) is
			-- Set value to `v'.
		do
			value := v
		ensure
			-- value_set: rabs (value - v) < epsilon
		end

	set_end_date (arg: DATE) is
			-- Set end_date to `arg'.
		require
			arg_not_void: arg /= Void
		do
			end_date := arg
		ensure
			end_date_set: end_date = arg and end_date /= Void
		end

end -- class SIMPLE_TUPLE
