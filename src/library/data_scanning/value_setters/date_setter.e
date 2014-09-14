note
	description: "Value setter that sets the date of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class DATE_SETTER inherit

	INTEGER_SETTER [TRADABLE_TUPLE]

creation

	make

feature -- Initialization

	make
		do
		end

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: TRADABLE_TUPLE)
			-- Expected format for date:  yyyymmdd
			-- Redefine in descendant for different formats.
		local
			date_time: DATE_TIME
			date: DATE
			date_util: expanded DATE_TIME_SERVICES
		do
			date := date_util.date_from_number (stream.last_integer)
			if date = Void then -- stream.last_integer was invalid
				handle_input_error ("Date input value is invalid.", Void)
				unrecoverable_error := True
			else
				create date_time.make_by_date (date)
				tuple.set_date_time (date_time)
			end
		end

end
