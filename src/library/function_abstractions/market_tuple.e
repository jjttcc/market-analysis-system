indexing
	description: 
		"Basic abstraction for a market-related value (or tuple of values) %
		%that has an associated date/time."
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_TUPLE

feature -- Access

	date_time: DATE_TIME
			-- The start date and time of the tuple

	value: REAL is
			-- Main value of the tuple
		deferred
		end

feature {FACTORY, VALUE_SETTER, MARKET_FUNCTION} -- Element change

	set_date_time (t: DATE_TIME) is
			-- Set date_time to `t'.
		require
			not_void: t /= Void
		do
			date_time := t
		ensure
			set: date_time = t and date_time /= Void
		end

end -- class MARKET_TUPLE
