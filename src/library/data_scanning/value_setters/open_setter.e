indexing
	description: "Value setter that sets the open value of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class OPEN_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: BASIC_MARKET_TUPLE) is
		do
			if stream.last_real < epsilon then
				handle_le_0_error ("opening price")
				-- conform to the postondition:
				tuple.set_open (0)
			else
				tuple.set_open (stream.last_real)
			end
		ensure then
			open_set_to_last_real_if_valid:
				stream.last_real >= 0 implies
					rabs (stream.last_real - tuple.open.value) < epsilon
			error_if_last_real_lt_0:
				stream.last_real < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies rabs (tuple.open.value) < epsilon
		end

end -- class OPEN_SETTER
