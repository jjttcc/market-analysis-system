indexing
	description: 
		"Basic abstraction for a market-related value (or tuple of values) that%
		%has an associated trading period."

deferred class MARKET_TUPLE

feature -- Access

	trading_period: TIME_PERIOD

	value: REAL is
		deferred
		end

end -- class MARKET_TUPLE
