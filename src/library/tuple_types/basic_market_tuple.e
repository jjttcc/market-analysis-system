indexing
	description: "Minimum data set needed for charting and analysis"
	Note: "!!!Check whether it's appropriate for PRICE attributes %
			%to be expanded!!!"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_MARKET_TUPLE inherit

	MARKET_TUPLE

	MATH_CONSTANTS

creation

	make

feature -- Initialization

	make is
		do
			!!open; !!close; !!high; !!low
			open.set_value (-1)
		ensure
			not open_available
			not editing
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

	editing: BOOLEAN
			-- Is this instance in the process of being edited?

feature -- Status setting

	begin_editing is
			-- Set editing state to true to allow changing values
			-- without violating the class invariant.  end_editing
			-- should be called after setting values to allow them
			-- to be checked again by the class invariant.
		require
			not_editing: not editing
		do
			editing := true
		ensure
			editing: editing
		end

	end_editing is
			-- Set editing state to false and ensure the class invariant.
		require
			prices_valid: 
					(low <= high and low <= close and close <= high) and
					(open_available implies low <= open and open <= high)
		do
			editing := false
		ensure
			not_editing: not editing
			prices_valid: 
					(low <= high and low <= close and close <= high) and
					(open_available implies low <= open and open <= high)
		end

feature -- {WHO?} Element change

	set (o, h, l, c: REAL) is
			-- Set the open, high, low, and close values.
		require
			h_l_c_valid: h >= l and l <= c and c <= h
			open_valid: o >= 0 implies l <= o and o <= h
			h_l_c_non_negative: l >= 0
		do
			if o >= 0 then
				open.set_value (o)
			else
				open.set_value (-1)
			end
			high.set_value (h)
			low.set_value (l)
			close.set_value (c)
		ensure
			h_l_c_set: high.value = h; low.value = l; close.value = c
			o_set_if_gt_0: o >= 0 implies open.value = o
			o_lt_0_not_open_available: o <= 0 implies not open_available
		end

	set_open (p: REAL) is
			-- Set open to `p'.
		require
			argument_valid:
				not editing implies p >= low.value and p <= high.value
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
			argument_valid:
				not editing implies p >= low.value and p <= high.value
			non_negative: p >= 0
		do
			close.set_value (p)
		ensure
			close_set: close.value = p
		end

	set_high (p: REAL) is
			-- Set high to `p'.
		require
			argument_valid:
				not editing implies p >= close.value and p >= open.value
			non_negative: p >= 0
		do
			high.set_value (p)
		ensure
			high_set: high.value = p
		end

	set_low (p: REAL) is
			-- Set low to `p'.
		require
			argument_valid:
				not editing implies p <= close.value and p <= open.value
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
	price_relationships: not editing implies
					(low <= high and low <= close and close <= high) and
					(open_available implies low <= open and open <= high)

end -- class BASIC_MARKET_TUPLE
