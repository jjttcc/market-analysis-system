indexing
	description:
		"A TERMINABLE list of MARKET_FUNCTIONs that sets each market %
		%function's innermost input to a dummy in its cleanup operation"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TERMINABLE_MARKET_FUNCTION_LIST inherit

	TERMINABLE

	LINKED_LIST [MARKET_FUNCTION]

	MARKET_FUNCTION_EDITOR
		export {NONE}
			all
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

creation

	make

feature -- Utility

	cleanup is
			-- Ensure that the output data lists of each market function
			-- are (recursively) cleared so that no extra data is stored
			-- to the file.
		local
			dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			from
				start
			until
				exhausted
			loop
				!STOCK!dummy_tradable.make ("dummy", period_types @ "daily")
				-- Set innermost input to an empty tradable to force the
				-- market function to clear its contents.
				item.set_innermost_input (dummy_tradable)
				forth
			end
		end

end -- TERMINABLE_MARKET_FUNCTION_LIST
