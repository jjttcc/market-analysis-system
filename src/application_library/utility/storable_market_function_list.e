indexing
	description:
		"A storable list of MARKET_FUNCTIONs that wipes out each market %
		%function before saving it to persistent store"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class STORABLE_MARKET_FUNCTION_LIST inherit

	STORABLE_LIST [MARKET_FUNCTION]
		redefine
			save
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		undefine
			copy, is_equal
		end

	MARKET_FUNCTION_EDITOR
		undefine
			copy, is_equal
		end

creation

	make

feature -- Utility

	save is
			-- Ensure that the output data lists of each market function
			-- are (recursively) cleared so that no extra data is stored to
			-- the file; then call precursor to save the remaining contents.
		local
			dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			from
				start
			until
				exhausted
			loop
				create {STOCK} dummy_tradable.make ("dummy", Void, Void)
				dummy_tradable.set_trading_period_type (
					period_types @ (period_type_names @ Daily))
				-- Set innermost input to an empty tradable to force the
				-- market function to clear its contents.
				item.set_innermost_input (dummy_tradable)
				forth
			end
			Precursor
		end

end -- STORABLE_MARKET_FUNCTION_LIST
