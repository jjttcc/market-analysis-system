
indexing
	description: "A stock split";
	date: "$Date$";
	revision: "$Revision$"

class

	STOCK_SPLIT

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

invariant

	num_denom_gt_0: numerator > 0 and denominator > 0

end -- class STOCK_SPLIT
