indexing
	description: "Value setter that sets the (daily) date of a tuple";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class DAY_DATE_SETTER inherit

	INTEGER_SETTER

creation

	make

feature -- Initialization

	make is
		do
		end

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: MARKET_TUPLE) is
			-- Expected format for date:  yyyymmdd
			-- Redefine in descendant for different formats.
		local
			date_time: DATE_TIME
			date: DATE
			time: TIME
		do
			date := date_util.date_from_number (stream.last_integer)
			if date = Void then -- stream.last_integer was invalid
				!!date_time.make_now
				handle_input_error ("Date input value is invalid: ",
									stream.last_integer.out)
			else
				!!time.make (0, 0, 0)
				!!date_time.make_by_date_time (date, time)
			end
			tuple.set_date_time (date_time)
		end

feature {NONE}

	date_util: expanded DATE_TIME_SERVICES

end -- class DAY_DATE_SETTER
