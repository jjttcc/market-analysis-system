indexing
	description: "Tuple factory that produces a TRADE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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
