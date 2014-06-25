note
	description: "Value setter that sets the date of a TRADE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADE_DATE_SETTER inherit

	INTEGER_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: TRADE)
			-- Expected format for date:  yyyymmdd
			-- Redefine in descendant for different formats.
		local
			date: DATE
		do
			date := date_util.date_from_number (stream.last_integer)
			if date = Void then -- stream.last_integer was invalid
				create date.make_now
				handle_input_error ("Date input value is invalid: ",
									stream.last_integer.out)
			end
			tuple.set_date (date)
		end

feature {NONE}

	date_util: expanded DATE_TIME_SERVICES

end -- class TRADE_DATE_SETTER
