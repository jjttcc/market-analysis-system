indexing
	description: "Tuple factory that produces a BASIC_MARKET_TUPLE";
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_TUPLE_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute is
		do
			!!product.make
		end

feature -- Access

	product: BASIC_MARKET_TUPLE

end -- class BASIC_TUPLE_FACTORY
