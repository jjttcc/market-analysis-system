indexing
	description: "A simple tuple that functions as a single value."
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_TUPLE

inherit

	MARKET_TUPLE

feature -- Access

	value: REAL

feature -- {WHOSHOULDTHISBE} -- Element change

	set_value (v: REAL) is
		do
			value := v
		end

end -- class SIMPLE_TUPLE
