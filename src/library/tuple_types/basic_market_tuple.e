indexing
	description: "Minimum data set needed for charting and analysis"
	note: "!!!Check whether it's appropriate for PRICE attributes %
			%to be expanded!!!"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_MARKET_TUPLE inherit

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
		--require
		--	argument_valid: p /= Void and p.value >= 0
		do
			open := p
		end

	set_close (p: expanded PRICE) is
		--require
		--	argument_valid: p /= Void and p.value >= 0
		do
			close := p
		end

	set_high (p: expanded PRICE) is
		--require
		--	argument_valid: p /= Void and p.value >= 0
		do
			high := p
		end

	set_low (p: expanded PRICE) is
		--require
		--	argument_valid: p /= Void and p.value >= 0
		do
			low := p
		end

invariant

	--prices_non_negative: open.value >= 0 and close.value >= 0 and
	--						high.value >= 0 and low.value >= 0
	--open_na_value: not open_available implies open.value = 0
	--item_definition: value = close.value
	--price_relationships: low <= high and low <= open and open <= high and
	--						low <= close and close <= high

end -- class BASIC_MARKET_TUPLE
