note
	description:
		"An event associated with a tradable such as a stock or bond"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class TRADABLE_EVENT inherit

	TYPED_EVENT

	GENERAL_UTILITIES
		export
			{NONE} all
		undefine
			is_equal
		end

	SIGNAL_TYPES
		undefine
			is_equal
		end

feature -- Access

	components: LIST [TRADABLE_EVENT]
			-- Contained events - Current if atomic
		deferred
		end

	guts: ARRAY [STRING]
			-- For persistent storage, the guts of the class instance -
			-- that is, the fields needed to determine if this instance
			-- is_equal to another one - converted to an array of strings
		deferred
		end

	unique_id: STRING
		do
			if cached_id = Void then
				cached_id := concatenation (guts)
			end
			Result := cached_id
		ensure then
			not_void: Result /= Void
		end

	tag: STRING
			-- Short identifying string for the event, such as a stock symbol
		deferred
		end

feature {NONE} -- Implementation

	cached_id: STRING

invariant

	components_not_void: components /= Void

end -- class TRADABLE_EVENT
