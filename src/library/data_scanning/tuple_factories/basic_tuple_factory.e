indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class BASIC_TUPLE_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

feature

	execute (arg: ANY) is
		do
			!!product.make
		end

feature -- Access

	product: BASIC_MARKET_TUPLE

end -- class BASIC_TUPLE_FACTORY
