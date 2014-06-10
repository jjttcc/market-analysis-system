note
	description: "Value setter that sets the value of a stock split";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SPLIT_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: STOCK_SPLIT)
		do
			if stream.last_real <= 0 then
				handle_input_error ("Numeric input value is <= 0: ",
									stream.last_real.out)
				-- conform to the postcondition:
				tuple.set_value (0)
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
