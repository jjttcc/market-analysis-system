indexing
	description: "Value setter that sets the low value of a tuple";
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class LOW_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: BASIC_MARKET_TUPLE) is
		do
			if stream.last_real < 0 then
				handle_input_error ("Numeric input value is < 0: ",
									stream.last_real.out)
				-- conform to the precondition:
				tuple.set_low (0)
			else
				tuple.set_low (stream.last_real)
			end
		ensure then
			low_set_to_last_real_if_valid:
				stream.last_real >= 0 implies
					rabs (stream.last_real - tuple.low.value) < epsilon
			error_if_last_real_lt_0:
				stream.last_real < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies rabs (tuple.low.value) < epsilon
		end

end -- class LOW_SETTER
