indexing
	description: "A stock index, such as the S&P 500";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class STOCK_INDEX inherit

	TRADABLE [BASIC_MARKET_TUPLE]
		redefine
			symbol, short_description
		end

creation

	make

feature -- Initialization

	make (s: STRING; type: TIME_PERIOD_TYPE) is
		do
			symbol := s
			arrayed_list_make (300)
			tradable_initialize (type)
		ensure
			symbol_set: symbol = s
			trading_period_type = type
		end

feature -- Access

	symbol: STRING

	short_description: STRING is "Stock Index"

end -- class STOCK_INDEX
