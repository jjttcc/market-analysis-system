indexing
	description: "Information on a trade that has not been completely closed"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class OPEN_TRADE

creation

	make

feature -- Initialization

	make (t: TRADE) is
		require
			t_not_void: t /= Void
			t_open: t.is_open
		do
			trade := t
		ensure
			trade_set: trade = t
		end

feature -- Access

	trade: TRADE
			-- Opening trade of the match

	original_units: INTEGER is
			-- Number of units traded
		do
			Result := trade.units
		ensure
			Result = trade.units
		end

	open_units: INTEGER is
			-- Number of units that have not been closed
		do
			Result := original_units - closed_units
		end

	closed_units: INTEGER
			-- Number of units that have been closed

feature -- Basic operations

	add_close (t: TRADE) is
			-- Add `t' as a closing trade.
		require
			t_not_void: t /= Void
			symbol_valid: t.symbol.is_equal (trade.symbol)
			units_le_open_units: t.units < open_units
			t_is_close: t.is_close
		do
			closed_units := closed_units + t.units
		ensure
			new_open_units: open_units = old open_units - t.units
			closed_units = old closed_units + t.units
		end

invariant

	units_relation: original_units - open_units = closed_units
	units_ge_0: closed_units >= 0 and original_units >= 0 and open_units >= 0
	open_units_gt_0: open_units > 0

end -- OPEN_TRADE
