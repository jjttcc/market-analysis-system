indexing
	description: "Value setter that sets the symbol of a stock split"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SPLIT_SYMBOL_SETTER inherit

	VALUE_SETTER

creation

	make

feature -- Initialization

	make (sp_file: STOCK_SPLIT_FILE; field_sep: CHARACTER) is
		require
			not_void: sp_file /= Void and field_sep /= Void
		do
			splits := sp_file
			!!symbol.make (6)
			field_separator := field_sep
		ensure
			set: splits = sp_file
			fsep_set: field_separator = field_sep
		end

feature {NONE}

	read_value (stream: ITERABLE_INPUT_SEQUENCE) is
		do
			from
				symbol.wipe_out
				stream.read_character
			until
				stream.last_character = field_separator
			loop
				symbol.extend (stream.last_character)
				stream.read_character
			end
			-- Set stream position to just before the last read
			-- field separator.
			stream.back
			splits.set_current_symbol (symbol)
		end

	do_set (stream: INPUT_SEQUENCE; tuple: STOCK_SPLIT) is
			-- Not needed
		do
		end

feature {NONE}

	splits: STOCK_SPLIT_FILE

	field_separator: CHARACTER

	symbol: STRING

end -- class SPLIT_SYMBOL_SETTER
