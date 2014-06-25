note
	description: "Value setter that sets the symbol of a stock split"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SPLIT_SYMBOL_SETTER inherit

	VALUE_SETTER [STOCK_SPLIT]

creation

	make

feature -- Initialization

	make (sp_file: STOCK_SPLIT_SEQUENCE)
		require
			not_void: sp_file /= Void
		do
			splits := sp_file
			create symbol.make (6)
		ensure
			set: splits = sp_file
		end

feature {NONE}

	read_value (stream: INPUT_SEQUENCE)
		do
			stream.read_string
			symbol := stream.last_string
			splits.set_current_symbol (symbol)
		end

	do_set (stream: INPUT_SEQUENCE; tuple: STOCK_SPLIT)
			-- Not needed
		do
		end

feature {NONE}

	splits: STOCK_SPLIT_SEQUENCE

	symbol: STRING

end -- class SPLIT_SYMBOL_SETTER
