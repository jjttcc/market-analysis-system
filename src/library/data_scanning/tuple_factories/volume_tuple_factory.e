indexing
	description: "Tuple factory that creates a BASIC_VOLUME_TUPLE";
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_TUPLE_FACTORY inherit

	BASIC_TUPLE_FACTORY
		redefine
			product, execute
		end

feature

	execute is
		do
			!!product.make
		end

feature -- Access

	product: BASIC_VOLUME_TUPLE

end -- class VOLUME_TUPLE_FACTORY
