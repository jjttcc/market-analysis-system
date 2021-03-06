note
	description:
		"Minimum data set needed for charting and analysis of a tradable"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class BASIC_TRADABLE_TUPLE inherit

	TRADABLE_TUPLE
		redefine
			has_additional_queries
		end

	MATH_CONSTANTS
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make
		do
			create open; create close; create high; create low
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

	value: DOUBLE
		do
			Result := close.value
		end

feature -- Status report

	has_additional_queries: BOOLEAN = True

	open_available: BOOLEAN
			-- Is opening price datum available?  (Included because
			-- some data formats exclude opening price.)
		do
			Result := not (open.value < 0.0)
		end

	editing: BOOLEAN
			-- Is this instance in the process of being edited?

	price_relationships_correct: BOOLEAN
		do
			Result := (low <= high and low <= close and close <= high) and
						(open_available implies low <= open and open <= high)
		end

feature -- Status setting

	begin_editing
			-- Set editing state to True to allow changing values
			-- without violating the class invariant.  end_editing
			-- should be called after setting values to allow them
			-- to be checked again by the class invariant.
		require
			not_editing: not editing
		do
			editing := True
		ensure
			editing: editing
		end

	end_editing
			-- Set editing state to False and ensure the class invariant.
		require
			prices_valid: 
					(low <= high and low <= close and close <= high) and
					(open_available implies low <= open and open <= high)
		do
			editing := False
		ensure
			not_editing: not editing
			prices_valid: price_relationships_correct
		end

feature {VALUE_SETTER, FACTORY} -- Status setting

	set (o, h, l, c: DOUBLE)
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

	set_open (p: DOUBLE)
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

	set_close (p: DOUBLE)
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

	set_high (p: DOUBLE)
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

	set_low (p: DOUBLE)
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

feature {DATA_SCANNER} -- Element adjustment

	fix_price_relationships
			-- Change prices so that price_relationships_correct is
			-- not violated.
		do
			if not price_relationships_correct then
				if low > close then low := close end
				if high < close then high := close end
				if open_available then
					if low > open then low := open end
					if high < open then high := open end
				end
			end
		ensure
			price_relationships_correct: price_relationships_correct
			close_open_not_changed: open = old open and close = old close
		end

invariant

	prices_non_negative: close.value >= 0 and high.value >= 0 and
							low.value >= 0 and
							(open.value >= 0 or not open_available)
	open_na_value: not open_available implies open.value < 0
	price_relationships: not editing implies price_relationships_correct

end -- class BASIC_TRADABLE_TUPLE
