indexing
	description:
		"An event associated with a market such as a stock or bond"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_EVENT inherit

	TYPED_EVENT

	GLOBAL_SERVICES
		export
			{NONE} all
		undefine
			is_equal
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		undefine
			is_equal
		end

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

	unique_id: STRING is
		do
			if cached_id = Void then
				cached_id := concatenation (guts)
			end
			Result := cached_id
		ensure then
			not_void: Result /= Void
		end

feature {NONE} -- Implementation

	cached_id: STRING

invariant

	components_not_void: components /= Void

end -- class MARKET_EVENT
