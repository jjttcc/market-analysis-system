indexing
	description: "A single-value tuple."
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_TUPLE inherit

	MARKET_TUPLE

feature -- Access

	value: REAL

feature {MARKET_FUNCTION} -- Element change

	set_value (v: REAL) is
			-- Set value to `v'.
		do
			value := v
		ensure
			value = v
		end

end -- class SIMPLE_TUPLE
