indexing
	description:
		"Abstraction for a table of stock split sequences, with the stock "
		"symbol as the key"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class

	STOCK_SPLITS inherit

feature -- Access

	infix "@" (symbol: STRING): DYNAMIC_CHAIN [STOCK_SPLIT] is
			-- Stock splits for the stock with `symbol' - Void if there
			-- are no recorded splits for `symbol'
		require
			symbol_valid: symbol /= Void and not symbol.empty
		deferred
		end

end -- class STOCK_SPLITS
