note
	description:
		"Interface for selecting a TRADABLE_FUNCTION's tradable tuple list"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	TRADABLE_TUPLE_LIST_SELECTOR

feature -- Access

	tradable_tuple_list_selection (msg: STRING): CHAIN [TRADABLE_TUPLE]
			-- User-selected list of tradable tuples
		deferred
		end

	tradable_function_selection (msg: STRING;
		validity_checker: FUNCTION [ANY, TUPLE [TRADABLE_FUNCTION], BOOLEAN]):
		TRADABLE_FUNCTION
			-- User-selected TRADABLE_FUNCTION from the function library,
			-- filtered with `validity_checker' if it's not Void.
		deferred
		ensure
			result_not_void: Result /= Void
		end

end -- TRADABLE_TUPLE_LIST_SELECTOR
