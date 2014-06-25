note
	description:
		"Abstraction for a table of stock split sequences, with the stock",
		"symbol as the key"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	STOCK_SPLITS inherit

feature -- Access

	infix "@" (symbol: STRING): DYNAMIC_CHAIN [STOCK_SPLIT]
			-- Stock splits for the stock with `symbol' - Void if there
			-- are no recorded splits for `symbol'
		require
			symbol_valid: symbol /= Void and not symbol.is_empty
		deferred
		end

end -- class STOCK_SPLITS
