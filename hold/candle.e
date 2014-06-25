indexing
	description:
		"Interpreter that analyzes a tuple with open, high, low, and %
		%close fields in terms of candlestick charting"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
