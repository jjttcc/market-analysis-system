indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class OPEN_INTEREST_SETTER inherit

	VALUE_SETTER

feature

	set (stream: IO_MEDIUM; tuple: OPEN_INTEREST_TUPLE) is
		do
			stream.read_integer
			check stream.last_integer >= 0 end
			tuple.set_open_interest (stream.last_integer)
		end

end -- class OPEN_INTEREST_SETTER
