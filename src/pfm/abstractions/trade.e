indexing
	description: "An execution of a buy or sell order"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADE inherit

	MATH_CONSTANTS
		export
			{NONE} all
			{ANY} epsilon
		end

	PORTFOLIO_MANAGEMENT_CONSTANTS

creation

	make

feature {NONE} -- Initialization

	make is
		do
			buy_or_sell := Buy
			open_or_close := Open
		ensure
			buy: buy_or_sell = Buy
			open: open_or_close = Open
		end

feature -- Access

	date: DATE
			-- Date the trade was entered

	buy_or_sell: INTEGER
			-- Type of order - buy or sell

	open_or_close: INTEGER
			-- Specification of whether the trade opens a new position
			-- or closes an existing one

	symbol: STRING
			-- Symbol of the traded item

	units: INTEGER
			-- Number of units traded

	price: REAL

	commission: REAL

feature -- Status setting

	set_date (arg: DATE) is
			-- Set date to `arg'.
		require
			arg_not_void: arg /= Void
		do
			date := arg
		ensure
			date_set: date = arg and date /= Void
		end

	set_buy_or_sell (arg: INTEGER) is
			-- Set buy_or_sell to `arg'.
		require
			b_or_s: arg = Buy or arg = Sell
		do
			buy_or_sell := arg
		ensure
			buy_or_sell_set: buy_or_sell = arg
		end

	set_open_or_close (arg: INTEGER) is
			-- Set open_or_close to `arg'.
		require
			o_or_c: arg = Open or arg = Close
		do
			open_or_close := arg
		ensure
			open_or_close_set: open_or_close = arg
		end

	set_symbol (arg: STRING) is
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

	set_units (arg: INTEGER) is
			-- Set units to `arg'.
		do
			units := arg
		ensure
			units_set: units = arg
		end

	set_price (arg: REAL) is
			-- Set price to `arg'.
		do
			price := arg
		ensure
			price_set: price - arg < epsilon
		end

	set_commission (arg: REAL) is
			-- Set commission to `arg'.
		do
			commission := arg
		ensure
			commission_set: commission - arg < epsilon
		end

invariant

	open_or_close_value: open_or_close = Open or open_or_close = Close

	buy_or_sell_value: buy_or_sell = Buy or buy_or_sell = Sell

end -- TRADE
