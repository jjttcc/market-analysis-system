indexing
	description: 
		"Interpreter that analyzes a tuple with open, high, low, and %
		%close fields in terms of candlestick charting"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	CANDLE

creation

	make

feature -- Initialization

	make (t: BASIC_MARKET_TUPLE) is
		require
			not_void: t /= Void
		do
			tuple := t
		ensure
			set: tuple = t
		end

feature -- Access

	type: INTEGER
			-- Type of candle, such as doji, long white, etc.

	tuple: BASIC_MARKET_TUPLE
			-- Tuple interpreted by this candle

feature -- Status report

	is_white: BOOLEAN
			-- Is this a white candle?

	is_black: BOOLEAN
			-- Is this a black candle?

invariant

	black_or_white: is_black = not is_white
	tuple_not_void: tuple /= Void

end -- class CANDLE
