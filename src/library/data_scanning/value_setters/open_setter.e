indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class OPEN_SETTER inherit

	VALUE_SETTER

feature

	set (stream: IO_MEDIUM; tuple: BASIC_MARKET_TUPLE) is
		do
			stream.read_real
			check stream.last_real >= 0 end
			tuple.set_open (stream.last_real)
		end

end -- class OPEN_SETTER
