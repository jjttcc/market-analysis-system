indexing
	description: "Tuple factory that produces a BASIC_MARKET_TUPLE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class BASIC_TUPLE_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute is
		do
			create product.make
		end

feature -- Access

	product: BASIC_MARKET_TUPLE

end -- class BASIC_TUPLE_FACTORY
