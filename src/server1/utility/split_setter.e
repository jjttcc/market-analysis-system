indexing
	description: "Value setter that sets the value of a stock split";
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SPLIT_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: STOCK_SPLIT) is
		do
			if stream.last_real <= 0 then
				handle_input_error ("Numeric input value is <= 0: ",
									stream.last_real.out)
				-- conform to the precondition:
				tuple.set_value (1)
			else
				tuple.set_value (stream.last_real)
			end
		ensure then
			value_set_to_last_real_if_valid:
				stream.last_real > 0 implies
					rabs (stream.last_real - tuple.value) < epsilon
			error_if_last_real_le_0:
				stream.last_real <= 0 implies error_occurred
			error_implies_tuple_set_to_1:
				error_occurred implies rabs (tuple.value - 1) < epsilon
		end

end -- class SPLIT_SETTER
