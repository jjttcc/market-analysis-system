note
	description: "Value setter that sets the time of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TIME_SETTER inherit

	STRING_SETTER

creation

	make

feature -- Initialization

	make
		do
		end

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: MARKET_TUPLE)
			-- Expected format for time:  hh:mm or hh:mm:ss
		local
			time: TIME
		do
			if stream.last_string /= Void then
				time := time_util.time_from_string (stream.last_string,
					field_separator)
			end
			if time = Void then -- stream.last_string was invalid
				handle_input_error ("Time input value is invalid: ",
					stream.last_string)
				unrecoverable_error := True
			else
				tuple.date_time.set_time (time)
			end
		end

feature {NONE}

	time_util: expanded DATE_TIME_SERVICES

	field_separator: STRING = ":"

end -- class TIME_SETTER
