indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_SETTER inherit

	VALUE_SETTER

feature

	set (stream: IO_MEDIUM; tuple: VOLUME_TUPLE) is
		do
			stream.read_integer
			check stream.last_integer >= 0 end
			tuple.set_volume (stream.last_integer)
		end

end -- class VOLUME_SETTER
