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

	adjust_for_split (ratio: REAL) is
			-- Adjust prices for stock split by the specified ratio.
		require
			gt_0: ratio > 0
		do
			open.set_value (open.value * ratio)
			high.set_value (high.value * ratio)
			low.set_value (low.value * ratio)
			close.set_value (close.value * ratio)
			adjust_volume_for_split (1 / ratio)
		ensure
			new_open: rabs (open.value - ratio * old open.value) < epsilon
			new_high: rabs (high.value - ratio * old high.value) < epsilon
			new_low: rabs (low.value - ratio * old low.value) < epsilon
			new_close: rabs (close.value - ratio * old close.value) < epsilon
			new_volume: rabs (volume - old volume / ratio) < epsilon
		end

feature {NONE} -- Implementation

	adjust_volume_for_split (r: REAL) is
		deferred
		end

invariant

	volume_ge_0: volume >= 0

end -- class VOLUME_TUPLE
