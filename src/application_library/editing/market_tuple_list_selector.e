indexing
	description:
		"Interface for selecting a MARKET_FUNCTION's market tuple list"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class

	MARKET_TUPLE_LIST_SELECTOR

feature -- Access

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
			-- User-selected list of market tuples
		deferred
		end

end -- MARKET_TUPLE_LIST_SELECTOR
