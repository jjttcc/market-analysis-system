indexing
	description: 
		"Basic abstraction for a market-related value (or tuple of values) that%
		% has an associated trading period."
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_TUPLE

feature -- Access

	trading_period: TIME_PERIOD

	value: REAL is
		deferred
		end

feature {TEST_FUNCTION_FACTORY, VALUE_SETTER, MARKET_FUNCTION} -- Element change

	set_trading_period (t: TIME_PERIOD) is
			-- Set trading_period to `t'.
		require
			not_void: t /= Void
		do
			trading_period := t
		ensure
			set: trading_period = t and trading_period /= Void
		end

end -- class MARKET_TUPLE
