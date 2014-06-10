note
	description: "Value setter that sets the high value of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class HIGH_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: BASIC_MARKET_TUPLE)
		do
			if stream.last_real < epsilon then
				handle_le_0_error ("highest price")
				-- conform to the postondition:
				tuple.set_high (0)
			else
				tuple.set_high (stream.last_real)
			end
		ensure then
			high_set_to_last_real_if_valid:
				stream.last_real >= 0 implies
					rabs (stream.last_real - tuple.high.value) < epsilon
			error_if_last_real_lt_0:
				stream.last_real < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies rabs (tuple.high.value) < epsilon
		end

end -- class HIGH_SETTER
