indexing
	description:
		"Interface for selecting a MARKET_FUNCTION's market tuple list"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	MARKET_TUPLE_LIST_SELECTOR

feature -- Access

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
			-- User-selected list of market tuples
		deferred
		end

	market_function_selection (msg: STRING;
		validity_checker: FUNCTION [ANY, TUPLE [MARKET_FUNCTION], BOOLEAN]):
		MARKET_FUNCTION is
			-- User-selected MARKET_FUNCTION from the function library,
			-- filtered with `validity_checker' if it's not Void.
		deferred
		ensure
			result_not_void: Result /= Void
		end

end -- MARKET_TUPLE_LIST_SELECTOR
