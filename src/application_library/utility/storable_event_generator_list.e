indexing
	description:
		"A list of MARKET_EVENT_GENERATORs that wipes out each %
		%generator in its cleanup operation"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TERMINABLE_EVENT_GENERATOR_LIST inherit

	TERMINABLE

	LINKED_LIST [MARKET_EVENT_GENERATOR]

	MARKET_FUNCTION_EDITOR
		export {NONE}
			all
		end

creation

	make

feature -- Utility

	cleanup is
			-- Call wipe_out on each item to ensure that no extra data
			-- is stored to the file.
		do
			from
				start
			until
				exhausted
			loop
				item.wipe_out
				forth
			end
		end

end -- TERMINABLE_EVENT_GENERATOR_LIST
