indexing
	description: "A simple tuple that functions as a single value."

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
