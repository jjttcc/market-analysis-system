indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class BASIC_TUPLE_FACTORY inherit

	TUPLE_FACTORY

feature

	execute (arg: ANY) is
		do
			!BASIC_MARKET_TUPLE!product.make
		end

end -- class BASIC_TUPLE_FACTORY
