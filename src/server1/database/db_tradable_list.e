indexing
	description: "A TRADABLE_LIST for a database implementation"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class DB_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			setup_input_medium
		end

creation
	make

feature -- Initialization

feature -- Access

--	item: TRADABLE [BASIC_MARKET_TUPLE] is
--		do
--			check
--				indices_equal: symbol_list.index = tradable_factories.index
--			end
--			if symbol_list.index  /= old_index then
--				last_tradable := cached_item (symbol_list.index)
--				if last_tradable = Void then
--					tradable_factories.item.set_symbol (symbol_list.item)
--					tradable_factories.item.execute
--                     last_tradable := tradable_factories.item.product
--                     add_to_cache (last_tradable, symbol_list.index)
--                     if tradable_factories.item.error_occurred then
--                       	print_errors (last_tradable,
--							tradable_factories.item.error_list)
--					end
--				end
--			end
--			Result:= last_tradable
--		end 

feature {NONE} -- Implementation

	setup_input_medium is
		local
			inp_seq: DB_INPUT_SEQUENCE
		do
		end
	
end -- class DB_TRADABLE_LIST
