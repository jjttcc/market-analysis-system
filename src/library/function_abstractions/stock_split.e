
indexing
	description: "A stock split";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	STOCK_SPLIT inherit

	ANY
		redefine
			is_equal
		end

creation

	make

feature -- Initialization

	make (num, denom: INTEGER; d: DATE) is
		require
			gt_0: num > 0 and denom > 0
			date_not_void: d /= Void
		do
			numerator := num
			denominator := denom
			date := d
		ensure
			nd_set: numerator = num and denominator = denom
			date_set: date = d
		end

feature -- Access

	numerator: INTEGER
			-- numerator of the value of the split

	denominator: INTEGER
			-- denominator of the value of the split

	value: REAL
			-- numerator / denominator

	date: DATE
			-- The date the split became effective

feature -- Status report

	is_equal (other: like Current): BOOLEAN is
		do
			Result := other.date.is_equal (date)
		ensure then
			Result = other.date.is_equal (date)
		end

invariant

	num_denom_gt_0: numerator > 0 and denominator > 0

end -- class STOCK_SPLIT
