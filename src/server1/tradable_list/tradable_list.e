indexing
	description:
		"An iterable list of tradables"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_LIST inherit

	LINEAR [TRADABLE [BASIC_MARKET_TUPLE]]

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

feature -- Access

	search_by_symbol (s: STRING) is
			-- Find the tradable whose associated symbol matches `s'.
		deferred
		ensure
			item /= Void implies item.symbol.is_equal (s)
			-- not (s in symbols) implies item = Void
		end

	symbols: LIST [STRING] is
			-- The symbol of each tradable
		deferred
		ensure
			Result /= Void
		end

end -- class TRADABLE_LIST
