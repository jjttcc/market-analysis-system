note
	description: "Value setter that sets the value of a stock split";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SPLIT_SETTER inherit

	REAL_SETTER [STOCK_SPLIT]

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: STOCK_SPLIT)
		do
			if stream.last_double <= 0 then
				handle_input_error ("Numeric input value is <= 0: ",
									stream.last_double.out)
				-- conform to the postcondition:
				tuple.set_value (0)
			else
				tuple.set_value (stream.last_double)
			end
		ensure then
			value_set_to_last_double_if_valid:
				stream.last_double > 0 implies
					dabs (stream.last_double - tuple.value) < epsilon
			error_if_last_double_le_0:
				stream.last_double <= 0 implies error_occurred
			error_implies_tuple_set_to_1:
				error_occurred implies dabs (tuple.value - 1) < epsilon
		end

end -- class SPLIT_SETTER
