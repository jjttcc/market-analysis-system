indexing
	description: "A stock split";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class STOCK_SPLIT inherit

	MARKET_TUPLE
		redefine
			is_equal
		end

	MATH_CONSTANTS
		export
			{NONE} all
		redefine
			is_equal
		end

feature -- Access

	value: REAL
			-- value of the split

	date: DATE is
			-- The date the split became effective
		do
			if date_time /= Void then
				Result := date_time.date
			end
		end

feature -- Status report

	is_equal (other: like Current): BOOLEAN is
		do
			Result := other.date.is_equal (date) and
						rabs (value - other.value) < epsilon
		ensure then
			date_value_equal: Result = other.date.is_equal (date) and
						rabs (value - other.value) < epsilon
		end

feature {VALUE_SETTER}

	set_value (v: REAL) is
			-- Set value to `v'.
		require
			gt_0: v > 0
		do
			value := v
		ensure
			value_set: rabs (value - v) < epsilon
		end

end -- class STOCK_SPLIT
