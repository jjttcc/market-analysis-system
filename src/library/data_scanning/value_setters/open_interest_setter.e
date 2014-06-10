note
	description: "Value setter that sets the open interest of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class OPEN_INTEREST_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE;
				tuple: BASIC_OPEN_INTEREST_TUPLE)
		do
			if stream.last_real + Epsilon < 0 then
				handle_input_error (Concatenation (<<"Numeric input value %
					%for open interest is less than 0: ", stream.last_real.out,
					"%Nadjusting to 0.">>), Void)
				-- conform to the postondition:
				tuple.set_open_interest (0)
			else
				tuple.set_open_interest (stream.last_real)
			end
		ensure then
			open_interest_set_to_last_real_if_valid:
				stream.last_real >= 0 implies
					stream.last_real - tuple.open_interest < Epsilon
			error_if_last_real_lt_0:
				stream.last_real < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies rabs (tuple.open_interest) < Epsilon
		end

end -- class OPEN_INTEREST_SETTER
