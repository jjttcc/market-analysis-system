indexing
	description: "Value setter that sets the open interest of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class OPEN_INTEREST_SETTER inherit

	INTEGER_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE;
				tuple: BASIC_OPEN_INTEREST_TUPLE) is
		do
			if stream.last_integer < 0 then
				handle_input_error ("Numeric input value is < 0: ",
									stream.last_integer.out)
				-- conform to the postondition:
				tuple.set_open_interest (0)
			else
				tuple.set_open_interest (stream.last_integer)
			end
		ensure then
			open_interest_set_to_last_integer_if_valid:
				stream.last_integer >= 0 implies
					stream.last_integer = tuple.open_interest
			error_if_last_integer_lt_0:
				stream.last_integer < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies tuple.open_interest = 0
		end

end -- class OPEN_INTEREST_SETTER
