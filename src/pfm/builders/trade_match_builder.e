indexing
	description: "Builder of TRADE_MATCH objects"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADE_MATCH_BUILDER inherit

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make (tlist: LIST [TRADE]) is
		require
			tlist_not_void: tlist /= Void
		do
			if not tlist.is_empty then
				make_trades (tlist)
			end
		end

feature -- Access

	product: LIST [TRADE_MATCH]

	open_trades: LINKED_LIST [OPEN_TRADE] is
			-- Remaining open trades - Void if none
		local
			ol: LINEAR [LIST [OPEN_TRADE]]
		do
			if open_trade_table /= Void then
				create Result.make
				ol := open_trade_table.linear_representation
				from
					ol.start
				until
					ol.exhausted
				loop
					Result.append (ol.item)
					ol.forth
				end
			end
		end

feature -- Basic operations

	execute is
		require
			not_built: product = Void
		do
			create {LINKED_LIST [TRADE_MATCH]} product.make
			create open_trade_table.make (0)
			make_open_trades
			match_trades
		ensure
			built: product /= Void
		end

feature {NONE} -- Implementation

	make_trades (l: LIST [TRADE]) is
		require
			l_not_empty: not l.is_empty
		local
			ttree: BINARY_SEARCH_TREE [TRADE]
		do
			from
				l.start
				create ttree.make (l.item)
				l.forth
			until
				l.exhausted
			loop
				ttree.extend (l.item)
				l.forth
			end
			if not ttree.sorted then
				ttree.sort
			end
			trades := ttree.linear_representation
		end

	make_open_trades is
		do
			from
				trades.start
			until
				trades.exhausted
			loop
				if trades.item.is_open then
					add_open_trade (trades.item)
				end
				trades.forth
			end
		end

	add_open_trade (t: TRADE) is
		local
			ot: OPEN_TRADE
			otl: LINKED_LIST [OPEN_TRADE]
		do
			otl := open_trade_table @ t.symbol
			if otl = Void then
				create otl.make
				open_trade_table.put (otl, t.symbol)
			end
			create ot.make (t)
			otl.extend (ot)
		end

	match_trades is
			-- Make a TRADE_MATCH for each close trade in `trades'.
		do
			from
				trades.start
			until
				trades.exhausted
			loop
				if trades.item.is_close then
					add_trade_match (trades.item)
				end
				trades.forth
			end
		end

	add_trade_match (t: TRADE) is
		local
			ot: OPEN_TRADE
			otl: LINKED_LIST [OPEN_TRADE]
		do
			otl := open_trade_table @ t.symbol
			if otl = Void or else otl.is_empty then
				handle_error (concatenation (<<"Open trade to match ",
					t.symbol, " for close on ", t.date,
					" not found.">>))
			else
				check
					otl_not_empty: not otl.is_empty
				end
				from
					otl.start
				until
					otl.exhausted or else otl.item.open_units = t.units
				loop
					otl.forth
				end
				if otl.exhausted then
					otl.start
				end
				ot := otl.item
				check
					open_trade_found: ot /= Void
				end
				product.extend (new_trade_match (ot, t))
				if t.units < ot.open_units then
					ot.add_close (t)
				else
					check ot = otl.item end
					-- Since all units of ot are now closed, it is no longer
					-- an open trade - remove it from the open trade list.
					otl.remove
					if t.units > ot.open_units then
						print (concatenation (<<"Found a close trade whose ",
							"units > the open units for that symbol (",
							t.symbol, ") -",
							"%Nclose units: ", t.units, ", open units: ",
							ot.open_units, "%N(Code to deal with this is",
							" not yet implemented.)%N">>))
						--[Create a new open trade with the remaining units
						--of t and put it into the trade list. ...]
					end
				end
			end
		end

	new_trade_match (ot: OPEN_TRADE; t: TRADE): TRADE_MATCH is
			-- A new TRADE_MATCH created from `ot' and `t'
		do
			create Result.make (ot.trade)
			Result.set_closing_trade (t)
		end

	handle_error (s: STRING) is
		do
			print (s); print ("%N")
		end

	open_trade_table: HASH_TABLE [LINKED_LIST [OPEN_TRADE], STRING]
			-- Record of trades still open, indexed by symbol

	trades: LINEAR [TRADE]
			-- All existing trades, sorted by date

end -- TRADE_MATCH_BUILDER
