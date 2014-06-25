note
	description: "Value setter that sets the units of a TRADE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADE_UNITS_SETTER inherit

	INTEGER_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: TRADE)
			-- Expected format for date:  yyyymmdd
			-- Redefine in descendant for different formats.
		do
			if stream.last_integer < 1 then
				handle_input_error ("Units input value is invalid: ",
									stream.last_integer.out)
			end
			tuple.set_units (stream.last_integer)
		end

end -- class TRADE_UNITS_SETTER
