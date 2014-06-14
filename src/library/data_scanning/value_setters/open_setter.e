note
	description: "Value setter that sets the open value of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class OPEN_SETTER inherit

	REAL_SETTER [BASIC_MARKET_TUPLE]

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: BASIC_MARKET_TUPLE)
		do
			if stream.last_double < epsilon then
				handle_le_0_error ("opening price")
				-- conform to the postondition:
				tuple.set_open (0)
			else
				tuple.set_open (stream.last_double)
			end
		ensure then
			open_set_to_last_double_if_valid:
				stream.last_double >= 0 implies
					dabs (stream.last_double - tuple.open.value) < epsilon
			error_if_last_double_lt_0:
				stream.last_double < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies dabs (tuple.open.value) < epsilon
		end

end -- class OPEN_SETTER
