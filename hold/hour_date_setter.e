indexing
	description: "Value setter that sets the date and hour of a tuple";
	date: "$Date$";
	revision: "$Revision$"

class HOUR_DATE_SETTER inherit

	VALUE_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: MARKET_TUPLE) is
		do
			--Stub!!!
			-- Tuples must always have a date.
			check not is_dummy end
			if stream.last_integer < 0 then
				!!last_error.make (128)
				last_error.append ("Numeric input value is < 0: ")
				last_error.append (stream.last_integer.out)
				-- conform to the precondition:
				tuple.set_close (0)
				error_occurred := true
			else
				-- !!!Set the date/time
				--!!!When the flyweight pattern is implemented for dates,
				--!!!will need to reference the global date (probably a
				--!!!singleton) that matches this one instead of making
				--!!!a new date.
			end
		end

end -- class HOUR_DATE_SETTER
