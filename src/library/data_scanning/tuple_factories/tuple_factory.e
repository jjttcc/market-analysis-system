indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

deferred class 
	TUPLE_FACTORY

feature -- Access

	product: MARKET_TUPLE

feature -- Basic operations

	execute is
			-- Manufacture a tuple
		deferred
		end

end -- class TUPLE_FACTORY
