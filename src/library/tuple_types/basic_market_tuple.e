indexing
	description: "Minimum data set needed for charting and analysis"
	date: "$Date$";
	revision: "$Revision$"

class STANDARD_MARKET_TUPLE inherit

	MARKET_TUPLE

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
		end

feature -- {WHO}

	set_open (p: expanded PRICE) is
		do
			open := p
		end

	set_close (p: expanded PRICE) is
		do
			close := p
		end

	set_high (p: expanded PRICE) is
		do
			high := p
		end

	set_low (p: expanded PRICE) is
		do
			low := p
		end

invariant

	--prices_non_negative: open >= 0 and close >= 0 and high >= 0 and low >= 0
	--open_na_value: not open_available implies open = 0
	--item_definition: item = close

end -- class STANDARD_MARKET_TUPLE
