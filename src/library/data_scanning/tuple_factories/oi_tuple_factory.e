indexing
	description: "Tuple factory that creates an OPEN_INTEREST_TUPLE";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class OI_TUPLE_FACTORY inherit

	VOLUME_TUPLE_FACTORY
		redefine
			product, execute
		end

feature

	execute is
		do
			!!product.make
		end

feature -- Access

	product: BASIC_OPEN_INTEREST_TUPLE

end -- class OI_TUPLE_FACTORY
