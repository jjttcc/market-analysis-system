indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class OPEN_INTEREST_SETTER inherit

	VALUE_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: OPEN_INTEREST_TUPLE) is
		do
			stream.read_integer
			-- Only set the field if it is not flagged as a dummy.
			if not is_dummy then
				if stream.last_integer < 0 then
					!!last_error.make (128)
					last_error.append ("Numeric input value is < 0: ")
					last_error.append (stream.last_integer.out)
					-- conform to the precondition:
					tuple.set_open_interest (0)
					error_occurred := true
				else
					tuple.set_open_interest (stream.last_integer)
				end
			end
		ensure then
			open_interest_set_to_last_integer:
				stream.last_integer = tuple.open_interest
		end

end -- class OPEN_INTEREST_SETTER
