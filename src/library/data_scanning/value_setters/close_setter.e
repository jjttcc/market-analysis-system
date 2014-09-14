note
	description: "Value setter that sets the close value of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CLOSE_SETTER inherit

	REAL_SETTER [BASIC_TRADABLE_TUPLE]

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: BASIC_TRADABLE_TUPLE)
		do
			if stream.last_double < epsilon then
				handle_le_0_error ("last price")
				-- conform to the postondition:
				tuple.set_close (0)
			else
				tuple.set_close (stream.last_double)
			end
		ensure then
			close_set_to_last_double_if_valid:
				stream.last_double >= 0 implies
					dabs (stream.last_double - tuple.close.value) < epsilon
			error_if_last_double_lt_0:
				stream.last_double < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies dabs (tuple.close.value) < epsilon
		end

end -- class CLOSE_SETTER
