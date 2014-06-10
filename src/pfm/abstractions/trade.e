note
	description: "An execution of a buy or sell order"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADE inherit

	MATH_CONSTANTS
		export
			{NONE} all
			{ANY} epsilon
		undefine
			is_equal
		end

	COMPARABLE
		redefine
			is_equal
		end

creation

	make

feature {NONE} -- Initialization

	make
		do
		ensure
			buy: is_buy
			open: is_open
		end

feature -- Access

	date: DATE
			-- Date the trade was entered

	is_buy: BOOLEAN
			-- Is the type of order for this trade a buy?
		do
			Result := not is_sell
		end

	is_sell: BOOLEAN
			-- Is the type of order for this trade a sell?

	is_open: BOOLEAN
			-- Is this an opening trade?
		do
			Result := not is_close
		end

	is_close: BOOLEAN
			-- Is this a closing trade?

	symbol: STRING
			-- Symbol of the traded item

	units: INTEGER
			-- Number of units traded

	price: REAL

	commission: REAL

feature -- Comparison

	infix "<" (other: like Current): BOOLEAN
		do
			if other = Current then
				Result := false
			elseif date = Void or other = Void then
				Result := date = Void and other /= Void
			else
				Result := date < other.date
			end
		end

	is_equal (other: like Current): BOOLEAN
		do
			if date = Void or other.date = Void then
				Result := date = Void and other.date = Void
			else
				Result := Precursor {COMPARABLE} (other)
			end
		end

feature -- Status setting

	set_date (arg: DATE)
			-- Set date to `arg'.
		require
			arg_not_void: arg /= Void
		do
			date := arg
		ensure
			date_set: date = arg and date /= Void
		end

	set_to_buy
			-- Set to a buy.
		do
			is_sell := false
		ensure
			is_buy
		end

	set_to_sell
			-- Set to a sell.
		do
			is_sell := true
		ensure
			is_sell
		end

	set_to_open
			-- Set to an opening trade.
		do
			is_close := false
		ensure
			is_open
		end

	set_to_close
			-- Set to a closing trade.
		do
			is_close := true
		ensure
			is_close
		end

	set_symbol (arg: STRING)
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

	set_units (arg: INTEGER)
			-- Set units to `arg'.
		do
			units := arg
		ensure
			units_set: units = arg
		end

	set_price (arg: REAL)
			-- Set price to `arg'.
		do
			price := arg
		ensure
			price_set: price - arg < epsilon
		end

	set_commission (arg: REAL)
			-- Set commission to `arg'.
		do
			commission := arg
		ensure
			commission_set: commission - arg < epsilon
		end

invariant

	buy_sell_exclusive: is_buy = not is_sell
	open_close_exclusive: is_open = not is_close

end -- TRADE
