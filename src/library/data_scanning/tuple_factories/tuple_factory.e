indexing
	description: "Abstraction of market tuple manufacturer";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class TUPLE_FACTORY inherit

	FACTORY

feature -- Access

	product: MARKET_TUPLE

feature -- Basic operations

	execute is
			-- Manufacture a tuple
		deferred
		end

end -- class TUPLE_FACTORY
