indexing
	description: "A basic market tuple with a volume attribute";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_TUPLE inherit

	BASIC_MARKET_TUPLE

creation

	make

feature -- Access

	volume: INTEGER
			-- Number of shares

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
		ensure
			rabs (open.value - ratio * old open.value) < epsilon
			rabs (high.value - ratio * old high.value) < epsilon
			rabs (low.value - ratio * old low.value) < epsilon
			rabs (close.value - ratio * old close.value) < epsilon
		end

feature {VALUE_SETTER, FACTORY}

	set_volume (v: INTEGER) is
			-- Set volume to `v'.
		require
			v >= 0
		do
			volume := v
		ensure
			volume = v
		end

invariant

	volume_ge_0: volume >= 0

end -- class VOLUME_TUPLE
