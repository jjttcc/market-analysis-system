indexing
	description: "Value setter that sets the time of a tuple";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TIME_SETTER inherit

	STRING_SETTER

creation

	make

feature -- Initialization

	make is
		do
		end

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: MARKET_TUPLE) is
			-- Expected format for time:  hh:mm or hh:mm:ss
		local
			time: TIME
		do
			if stream.last_string /= Void then
				time := time_util.time_from_string (stream.last_string,
					field_separator)
			end
			if time = Void then -- stream.last_string was invalid
				handle_input_error ("Time input value is invalid.", Void)
				unrecoverable_error := true
			else
				tuple.date_time.set_time (time)
			end
		end

feature {NONE}

	time_util: expanded DATE_TIME_SERVICES

	field_separator: STRING is ":"

end -- class TIME_SETTER
