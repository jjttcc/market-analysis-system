indexing
	description: "Builder of TRADE_MATCH objects"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADE_MATCH_BUILDER inherit

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	PORTFOLIO_MANAGEMENT_CONSTANTS
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make (telist: LIST [TRADE]) is
		require
			telist_not_void: telist /= Void
		do
			trade_entries := telist
		ensure
			trade_entries = telist
		end

feature -- Access

	product: LIST [TRADE_MATCH]

	trade_entries: LIST [TRADE]

feature -- Basic operations

	execute is
		require
			not_built: product = Void
		do
			create {LINKED_LIST [TRADE_MATCH]} product.make
			from
				trade_entries.start
			until
				trade_entries.exhausted
			loop
				if trade_entries.item.open_or_close = Open then
					product.force (make_trade (trade_entries.item))
				else
					close_trade (trade_entries.item)
				end
				trade_entries.forth
			end
		ensure
			built: product /= Void
		end

feature {NONE} -- Implementation

	make_trade (entry: TRADE): TRADE_MATCH is
		require
			is_open: entry.open_or_close = Open
		local
			short_trade: BOOLEAN
		do
			short_trade := entry.buy_or_sell = Sell
			create Result.make (Void, entry.symbol, entry.date,
				entry.price, entry.units, short_trade)
		end

	close_trade (entry: TRADE) is
		require
			is_close: entry.open_or_close = Close
		local
			cursor: CURSOR
			found: BOOLEAN
		do
			cursor := product.cursor
			from
				product.start
			until
				found or product.exhausted
			loop
				if
					product.item.symbol.is_equal (entry.symbol) and
					not product.item.closed
				then
					if
						product.item.short and entry.buy_or_sell = Buy or
						not product.item.short and entry.buy_or_sell = Sell
					then
						product.item.close (entry.price, entry.date)
						found := true
					end
				end
				product.forth
			end
			if not found then
				handle_error (concatenation (<<"Open trade entry to match ",
					entry.symbol, " for close on ", entry.date,
					" not found.">>))
			end
			product.go_to (cursor)
		end

	handle_error (s: STRING) is
		do
			print (s); print ("%N")
		end

end -- TRADE_MATCH_BUILDER
