indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class CLOSE_SETTER inherit

	VALUE_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: BASIC_MARKET_TUPLE) is
		do
			stream.read_real
			-- Only set the field if it is not flagged as a dummy.
			if not is_dummy then
				if stream.last_real < 0 then
					!!last_error.make (128)
					last_error.append ("Numeric input value is < 0: ")
					last_error.append (stream.last_real.out)
					-- conform to the precondition:
					tuple.set_close (0)
					error_occurred := true
				else
					tuple.set_close (stream.last_real)
				end
			end
		ensure then
			close_set_to_last_real:
				rabs (stream.last_real - tuple.close.value) < epsilon
		end

end -- class CLOSE_SETTER
