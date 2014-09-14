note
	description: "A basic tradable tuple with a volume feature";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class VOLUME_TUPLE inherit

	BASIC_TRADABLE_TUPLE

feature -- Access

	volume: DOUBLE
			-- Number of shares
		deferred
		end

feature -- Element change

	adjust_for_split (v: DOUBLE)
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
			new_open: dabs (open.value - old open.value / v) < epsilon
			new_high: dabs (high.value - old high.value / v) < epsilon
			new_low: dabs (low.value - old low.value / v) < epsilon
			new_close: dabs (close.value - old close.value / v) < epsilon
			new_volume: dabs (volume - old volume * v) < epsilon
		end

feature {NONE} -- Implementation

	adjust_volume_for_split (r: DOUBLE)
		deferred
		end

invariant

	volume_ge_0: volume >= 0

end -- class VOLUME_TUPLE
