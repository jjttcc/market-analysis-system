indexing
	description:
		"A storable list of MARKET_EVENT_GENERATORs that wipes out each %
		%generator before saving it to persistent store."
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STORABLE_EVENT_GENERATOR_LIST inherit

	STORABLE_LIST [MARKET_EVENT_GENERATOR]
		redefine
			cleanup
		end

	MARKET_FUNCTION_EDITOR
		export {NONE}
			all
		end

creation

	make

feature -- Utility

	cleanup is
			-- Call wipe_out on each item to ensure that no extra data
			-- is stored to the file; then call precursor.
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

end -- STORABLE_EVENT_GENERATOR_LIST
