indexing
	description: "Value setter that sets the date and hour of a tuple";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class HOUR_DATE_SETTER inherit

	INTEGER_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: MARKET_TUPLE) is
		do
			--Stub!!!
			if stream.last_integer < 0 then
				handle_input_error ("Numeric input value is < 0: ",
									stream.last_integer.out)
				-- conform to the precondition:
				tuple.set_close (0)
			else
				-- !!!Set the date/time
				--!!!When the flyweight pattern is implemented for dates,
				--!!!will need to reference the global date (probably a
				--!!!singleton) that matches this one instead of making
				--!!!a new date.
			end
		end

end -- class HOUR_DATE_SETTER
