indexing
	description: "Miscellaneous information about a stock";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class STOCK_DATA

feature -- Access

	symbol: STRING

	name: STRING is
			-- Name of stock associated with `symbol'
		deferred
		end

	description: STRING is
			-- Description of stock associated with `symbol'
		deferred
		end

	sector: STRING is
			-- Name of sector of stock associated with `symbol'
		deferred
		end

feature -- Status setting

	set_symbol (arg: STRING) is
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

end -- class STOCK_DATA
