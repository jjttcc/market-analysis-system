indexing
	description: "Tuple factory that produces a TRADE";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADE_FACTORY inherit

	FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute is
		do
			create product.make
		end

feature -- Access

	product: TRADE

end -- class TRADE_FACTORY
