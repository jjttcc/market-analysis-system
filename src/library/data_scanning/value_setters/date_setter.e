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
		do
			date := date_util.date_from_number (stream.last_integer)
			if date = Void then -- stream.last_integer was invalid
				handle_input_error ("Date input value is invalid.", Void)
				unrecoverable_error := true
			else
				create date_time.make_by_date (date)
				tuple.set_date_time (date_time)
			end
		end

feature {NONE}

	date_util: expanded DATE_TIME_SERVICES

end -- class DAY_DATE_SETTER
