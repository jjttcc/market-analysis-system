indexing
	description:
		"A storable list of MARKET_FUNCTIONs that wipes out each market %
		%function before saving it to persistent store"
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
			-- to the file; then call precursor.
		local
			dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			from
				start
			until
				exhausted
			loop
				!STOCK!dummy_tradable.make ("dummy",
					period_types @ (period_type_names @ Daily))
				-- Set innermost input to an empty tradable to force the
				-- market function to clear its contents.
				item.set_innermost_input (dummy_tradable)
				forth
			end
			Precursor
		end

end -- STORABLE_MARKET_FUNCTION_LIST
