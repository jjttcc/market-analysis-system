indexing
	description: "Facilities for processing TRADABLEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	TRADABLE_FACILITIES

inherit

feature -- Status report

	valid_stock_processor (f: MARKET_PROCESSOR): BOOLEAN is
			-- Is `f' a valid processor for a STOCK instance - that is,
			-- are all of its `operators' valid for a STOCK?
		local
			cmds: LIST [COMMAND]
			oi: OPEN_INTEREST
		do
			cmds := f.operators
			Result := True
			from cmds.start until not Result or cmds.exhausted loop
				oi ?= cmds.item
				-- Currently, the only invalid operator for a STOCK is
				-- open interest.
				if oi /= Void then
					Result := False
				end
				cmds.forth
			end
		end

end
