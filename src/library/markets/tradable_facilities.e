note
	description: "Facilities for processing TRADABLEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	TRADABLE_FACILITIES

inherit

feature -- Status report

	valid_stock_processor (f: MARKET_PROCESSOR): BOOLEAN
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
