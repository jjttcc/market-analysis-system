indexing
	description:
		"Abstraction for a table of stock split sequences, with the stock "
		"symbol as the key"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class

	STOCK_SPLITS inherit

feature -- Access

	infix "@" (symbol: STRING): DYNAMIC_CHAIN [STOCK_SPLIT] is
			-- Stock splits for the stock with `symbol' - empty if there
			-- are no recorded splits for `symbol'
		require
			symbol_valid: symbol /= Void and not symbol.empty
		deferred
		ensure
			Result /= Void
		end

end -- class STOCK_SPLITS
