indexing
	description: "Abstraction of market tuple manufacturer";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
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

feature -- Status report

	arg_mandatory: BOOLEAN is false

end -- class TUPLE_FACTORY
