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

invariant

	components_not_void: components /= Void

end -- class MARKET_EVENT
