indexing
	description: "Tuple factory that produces a STOCK_SPLIT";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STOCK_SPLIT_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute is
		do
			!!product
		end

feature -- Access

	product: STOCK_SPLIT

end -- class STOCK_SPLIT_FACTORY
