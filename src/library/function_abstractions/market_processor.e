indexing
	description:
		"Objects that perform processing on market data using one or %
		%more MARKET_FUNCTIONs and COMMANDs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MARKET_PROCESSOR inherit

feature -- Access

	functions: LIST [MARKET_FUNCTION] is
			-- All functions used directly or indirectly by this market
			-- processor, including itself, if it is a function
		deferred
		ensure
			not_void: Result /= Void
		end

	parameters: LIST [FUNCTION_PARAMETER] is
			-- Changeable parameters for `functions'
		deferred
		ensure
			not_void: Result /= Void
		end

	operators: LIST [COMMAND] is
			-- All operators used directly or indirectly by this market
			-- processor, including those used by `functions'
		deferred
		ensure
			not_void: Result /= Void
		end

end -- class MARKET_PROCESSOR