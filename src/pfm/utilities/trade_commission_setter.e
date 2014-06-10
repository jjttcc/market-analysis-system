note
	description: "Value setter that sets the commission of a TRADE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADE_COMMISSION_SETTER inherit

	REAL_SETTER

feature {NONE}

	do_set (stream: INPUT_SEQUENCE; tuple: TRADE)
		do
			if stream.last_real < 0 then
				handle_input_error ("Numeric input value is < 0: ",
									stream.last_real.out)
				-- conform to the precondition:
				tuple.set_commission (0)
			else
				tuple.set_commission (stream.last_real)
			end
		ensure then
			commission_set_to_last_real_if_valid:
				stream.last_real >= 0 implies
					rabs (stream.last_real - tuple.commission) < epsilon
			error_if_last_real_lt_0:
				stream.last_real < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies rabs (tuple.commission) < epsilon
		end

end -- class TRADE_COMMISSION_SETTER
