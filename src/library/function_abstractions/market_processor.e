note
	description:
		"Objects that perform processing on market data using one or %
		%more MARKET_FUNCTIONs and COMMANDs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class MARKET_PROCESSOR inherit

feature -- Access

	functions: LIST [FUNCTION_PARAMETER]
			-- All functions used directly or indirectly by this market
			-- processor, including itself, if it is a function
		deferred
		ensure
			not_void: Result /= Void
		end

	parameters: LIST [FUNCTION_PARAMETER]
			-- Changeable parameters for `functions'
		deferred
		ensure
			not_void: Result /= Void
		end

	operators: LIST [COMMAND]
			-- All operators used directly or indirectly by this market
			-- processor, including those used by `functions'
		deferred
		ensure
			not_void: Result /= Void
		end

end -- class MARKET_PROCESSOR
