indexing
	description: "A basic market tuple with a volume feature";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class VOLUME_TUPLE inherit

	BASIC_MARKET_TUPLE

feature -- Access

	volume: INTEGER is
			-- Number of shares
		deferred
		end

feature -- Element change

	adjust_for_split (v: REAL) is
			-- Adjust prices for stock split by `v' by dividing each
			-- price field by `v' and multiplying volume by `v'.
		require
			gt_0: v > 0
		do
			open.set_value (open.value / v)
			high.set_value (high.value / v)
			low.set_value (low.value / v)
			close.set_value (close.value / v)
			adjust_volume_for_split (v)
		ensure
			new_open: rabs (open.value - v / old open.value) < epsilon
			new_high: rabs (high.value - v / old high.value) < epsilon
			new_low: rabs (low.value - v / old low.value) < epsilon
			new_close: rabs (close.value - v / old close.value) < epsilon
			new_volume: rabs (volume - old volume * v) < epsilon
		end

feature {NONE} -- Implementation

	adjust_volume_for_split (r: REAL) is
		deferred
		end

invariant

	volume_ge_0: volume >= 0

end -- class VOLUME_TUPLE
