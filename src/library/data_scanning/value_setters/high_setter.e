indexing
	description: "Value setter that sets the high value of a tuple";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class HIGH_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: BASIC_MARKET_TUPLE) is
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
