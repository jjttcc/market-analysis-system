indexing
	description: "Abstraction of market tuple manufacturer";
	date: "$Date$";
	revision: "$Revision$"

deferred class TUPLE_FACTORY inherit

	FACTORY

feature -- Access

	product: MARKET_TUPLE

feature -- Basic operations

	execute (arg: ANY) is
			-- Manufacture a tuple
		deferred
		end

end -- class TUPLE_FACTORY
