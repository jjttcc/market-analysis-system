indexing
	description: "Value setter that sets the symbol of a stock split"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class SPLIT_SYMBOL_SETTER inherit

	VALUE_SETTER

creation

	make

feature -- Initialization

	make (sp_file: STOCK_SPLIT_SEQUENCE) is
		require
			not_void: sp_file /= Void
		do
			splits := sp_file
			create symbol.make (6)
		ensure
			set: splits = sp_file
		end

feature {NONE}

	read_value (stream: INPUT_SEQUENCE) is
		do
			stream.read_string
			symbol := stream.last_string
			splits.set_current_symbol (symbol)
		end

	do_set (stream: INPUT_SEQUENCE; tuple: STOCK_SPLIT) is
			-- Not needed
		do
		end

feature {NONE}

	splits: STOCK_SPLIT_SEQUENCE

	symbol: STRING

end -- class SPLIT_SYMBOL_SETTER
