indexing
	description:
		"A storable list of MARKET_FUNCTIONs that wipes out each market %
		%function before saving it to persistent store."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STORABLE_MARKET_FUNCTION_LIST inherit

	STORABLE_LIST [MARKET_FUNCTION]
		redefine
			cleanup
		end

	MARKET_FUNCTION_EDITOR
		export {NONE}
			all
		end

	GLOBAL_SERVICES -- Needed for period_types
		export {NONE}
			all
		end

creation

	make

feature -- Utility

	cleanup is
			-- Set the innermost input function to an empty function so
			-- that no extra data is stored to the file; then call precursor.
		do
			from
				start
			until
				exhausted
			loop
				item.wipe_out
				forth
			end
			Precursor
		end

end -- STORABLE_MARKET_FUNCTION_LIST
