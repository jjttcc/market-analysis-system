indexing
	description: "Value setter that sets the buy/sell or open/closed state %
		%of a TRADE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class TRADE_CHAR_SETTER inherit

	VALUE_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: TRADE) is
			-- Expected format for date:  yyyymmdd
			-- Redefine in descendant for different formats.
		local
			s: STRING
		do
			stream.read_character
			if stream.last_character = Sell_string @ 1 then
				tuple.set_to_sell
				use_up (stream, Sell_string)
			elseif stream.last_character = Buy_string @ 1 then
				tuple.set_to_buy
				use_up (stream, Buy_string)
			elseif stream.last_character = Open_string @ 1 then
				tuple.set_to_open
				use_up (stream, Open_string)
			elseif stream.last_character = Close_string @ 1 then
				tuple.set_to_close
				use_up (stream, Close_string)
			else
				create s.make (1)
				s.append_character (stream.last_character)
				handle_input_error ("Illegal character: ", s)
			end
		end

	read_value (stream: INPUT_SEQUENCE) is
		do
			-- Null action
		end

	use_up (stream: INPUT_SEQUENCE; word: STRING) is
		local
			i, wsize: INTEGER
			error: BOOLEAN
			s: STRING
		do
			wsize := word.count
			from
				i := 2
			until
				error or i = wsize + 1
			loop
				stream.read_character
				if stream.last_character /= word @ i then
					create s.make (1)
					s.append_character (stream.last_character)
					handle_input_error ("Illegal character: ", s)
					error := true
				end
				i := i + 1
			end
			stream.read_character
		end

	Buy_string: STRING is "buy"

	Open_string: STRING is "open"

	Close_string: STRING is "close"

	Sell_string: STRING is "sell"

end -- class TRADE_CHAR_SETTER
