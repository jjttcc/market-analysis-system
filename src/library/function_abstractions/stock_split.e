
indexing
	description: "A stock split";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STOCK_SPLIT inherit

	ANY
		redefine
			is_equal
		end

	MATH_CONSTANTS
		export
			{NONE} all
		redefine
			is_equal
		end

creation

	make

feature -- Initialization

	make (v: REAL; d: DATE) is
		require
			gt_0: v > 0
			date_not_void: d /= Void
		do
			value := v
			date := d
		ensure
			value_set: rabs (value - v) < epsilon
			date_set: date = d
		end

feature -- Access

	value: REAL
			-- value of the split

	date: DATE
			-- The date the split became effective

feature -- Status report

	is_equal (other: like Current): BOOLEAN is
		do
			Result := other.date.is_equal (date) and
						rabs (value - other.value) < epsilon
		ensure then
			date_value_equal: Result = other.date.is_equal (date) and
						rabs (value - other.value) < epsilon
		end

invariant

	value_gt_0: value > 0

end -- class STOCK_SPLIT
