indexing
	description: "Value setter that sets the open interest of a tuple";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class OPEN_INTEREST_SETTER inherit

	INTEGER_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: OPEN_INTEREST_TUPLE) is
		do
			if stream.last_integer < 0 then
				handle_input_error ("Numeric input value is < 0: ",
									stream.last_integer.out)
				-- conform to the precondition:
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
