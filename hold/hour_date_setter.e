indexing
	description: "Value setter that sets the date and hour of a tuple";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class HOUR_DATE_SETTER inherit

	INTEGER_SETTER

feature {NONE}

	do_set (stream: BILINEAR_INPUT_SEQUENCE; tuple: MARKET_TUPLE) is
		do
			--Stub
			if stream.last_integer < 0 then
				handle_input_error ("Numeric input value is < 0: ",
									stream.last_integer.out)
				-- conform to the precondition:
				tuple.set_close (0)
			else
				-- Set the date/time
			end
		end

end -- class HOUR_DATE_SETTER
