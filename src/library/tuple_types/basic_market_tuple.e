indexing
	description: "Minimum data set needed for charting and analysis"
	Note: "!!!Check whether it's appropriate for PRICE attributes %
			%to be expanded!!!"
	Note2: "set takes type REAL_REF for its arguments instead of REAL %
			%because of a bug in the ISE environment that causes problems %
			%with assigning real values; the bug does not appear in the %
			%compiled (finalized) system."
	date: "$Date$";
	revision: "$Revision$"

class BASIC_MARKET_TUPLE inherit

	MARKET_TUPLE

creation

	make

feature -- Initialization

	make is
		do
			!!open; !!close; !!high; !!low
			open.set_value (-1)
		ensure
			not open_available
		end

feature -- Access

	open: PRICE
			-- opening price

	close: PRICE
			-- closing price

	high: PRICE
			-- highest price

	low: PRICE
			-- lowest price

	h_l_midpoint: PRICE is
			-- midpoint between high and low
		do
		end

	o_c_midpoint: PRICE is
			-- midpoint between open and close
		do
		end

	value: REAL is
		do
			Result := close.value
		end

feature -- Status report

	open_available: BOOLEAN is
			-- Is opening price datum available?  (Included because
			-- some data formats exclude opening price.)
		do
			Result := not (open.value < 0.0)
		end

feature -- {WHO?} Element change

	set (o, h, l, c: REAL_REF) is
			-- Set the open, high, low, and close values.
		require
			make_sense: h >= l and l <= o and o <= h and l <= c and c <= h
			non_negative: l.item >= 0
		do
			open.set_value (o.item)
			high.set_value (h.item)
			low.set_value (l.item)
			close.set_value (c.item)
		ensure
			values_set: open.value = o; high.value = h; low.value = l;
							close.value = c
			open_available: open_available
		end

	set_open (p: REAL) is
			-- Set open to `p'.
		require
			argument_valid: p >= low.value and p <= high.value
			non_negative: p >= 0
		do
			open.set_value (p)
		ensure
			open_set: open.value = p
			open_available: open_available
		end

	set_close (p: REAL) is
			-- Set close to `p'.
		require
			argument_valid: p >= low.value and p <= high.value
			non_negative: p >= 0
		do
			close.set_value (p)
		ensure
			close_set: close.value = p
		end

	set_high (p: REAL) is
			-- Set high to `p'.
		require
			argument_valid: p >= close.value and p >= open.value
			non_negative: p >= 0
		do
			high.set_value (p)
		ensure
			high_set: high.value = p
		end

	set_low (p: REAL) is
			-- Set low to `p'.
		require
			argument_valid: p <= close.value and p <= open.value
			non_negative: p >= 0
		do
			low.set_value (p)
		ensure
			low_set: low.value = p
		end

invariant

	prices_non_negative: close.value >= 0 and high.value >= 0 and
							low.value >= 0 and
							(open.value >= 0 or not open_available)
	open_na_value: not open_available implies open.value < 0
	price_relationships: low <= high and low <= close and close <= high;
						open_available implies open <= high and low <= open

end -- class BASIC_MARKET_TUPLE
