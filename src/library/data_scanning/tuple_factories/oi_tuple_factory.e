indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class OI_TUPLE_FACTORY inherit

	TUPLE_FACTORY

feature

	execute is
		do
			!OPEN_INTEREST_TUPLE!product.make
		end

end -- class OI_TUPLE_FACTORY
