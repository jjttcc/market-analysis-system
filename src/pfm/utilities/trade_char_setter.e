note
	description: "Value setter that sets the buy/sell or open/closed state %
		%of a TRADE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADE_CHAR_SETTER inherit

	VALUE_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: TRADE)
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

	read_value (stream: INPUT_SEQUENCE)
		do
			-- Null action
		end

	use_up (stream: INPUT_SEQUENCE; word: STRING)
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

	Buy_string: STRING = "buy"

	Open_string: STRING = "open"

	Close_string: STRING = "close"

	Sell_string: STRING = "sell"

end -- class TRADE_CHAR_SETTER
