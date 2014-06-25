note
	description: "Value setter that sets the open interest of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class OPEN_INTEREST_SETTER inherit

	REAL_SETTER [BASIC_OPEN_INTEREST_TUPLE]

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: BASIC_OPEN_INTEREST_TUPLE)
		do
			if stream.last_double + Epsilon < 0 then
				handle_input_error (Concatenation (<<"Numeric input value %
					%for open interest is less than 0: ",
					stream.last_double.out, "%Nadjusting to 0.">>), Void)
				-- conform to the postondition:
				tuple.set_open_interest (0)
			else
				tuple.set_open_interest (stream.last_double)
			end
		ensure then
			open_interest_set_to_last_double_if_valid:
				stream.last_double >= 0 implies
					stream.last_double - tuple.open_interest < Epsilon
			error_if_last_double_lt_0:
				stream.last_double < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies dabs (tuple.open_interest) < Epsilon
		end

end -- class OPEN_INTEREST_SETTER
