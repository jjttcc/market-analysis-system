indexing
	description:
		"An event associated with a market such as a stock or bond"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_EVENT inherit

	TYPED_EVENT

feature -- Access

	components: LIST [MARKET_EVENT] is
			-- Contained events - Current if atomic
		deferred
		end

	guts: ARRAY [STRING] is
			-- For persistent storage, the guts of the class instance -
			-- that is, the fields needed to determine if this instance
			-- is_equal to another one - converted to an array of strings
		deferred
		end

invariant

	components_not_void: components /= Void

end -- class MARKET_EVENT
