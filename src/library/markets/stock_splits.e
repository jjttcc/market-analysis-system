indexing
	description:
		"Abstraction for a table of stock split sequences, with the stock "
		"symbol as the key"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	STOCK_SPLITS inherit

feature -- Access

	infix "@" (symbol: STRING): DYNAMIC_CHAIN [STOCK_SPLIT] is
			-- Stock splits for the stock with `symbol' - Void if there
			-- are no recorded splits for `symbol'
		require
			symbol_valid: symbol /= Void and not symbol.is_empty
		deferred
		end

end -- class STOCK_SPLITS
