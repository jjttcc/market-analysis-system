indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class LOW_SETTER inherit

	VALUE_SETTER

feature

	set (stream: IO_MEDIUM; tuple: BASIC_MARKET_TUPLE) is
		do
			stream.read_real
			check stream.last_real >= 0 end
			tuple.set_low (stream.last_real)
		end

end -- class LOW_SETTER
