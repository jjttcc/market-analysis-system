note
	description: "Value setter that sets the symbol of a TRADE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADE_SYMBOL_SETTER inherit

	VALUE_SETTER

creation

	make

feature -- Initialization

	make (field_sep: CHARACTER)
		require
			not_void: field_sep /= Void
		do
			create symbol.make (6)
			field_separator := field_sep
		ensure
			fsep_set: field_separator = field_sep
			symbol_not_void: symbol /= Void
		end

feature {NONE}

	read_value (stream: ITERABLE_INPUT_SEQUENCE)
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
		end

	do_set (stream: ITERABLE_INPUT_SEQUENCE; tuple: TRADE)
			-- Not needed
		do
			tuple.set_symbol (clone (symbol))
		end

feature {NONE}

	field_separator: CHARACTER

	symbol: STRING

end -- class TRADE_SYMBOL_SETTER
