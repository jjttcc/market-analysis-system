indexing
	description: "Pair of an opening trade with a matching closing trade"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADE_MATCH inherit

	PFM_MATH_CONSTANTS
		export
			{NONE} all
			{ANY} epsilon, rabs
		end

creation

	make

feature -- Initialization

	make (trade: TRADE) is
		require
			trade_not_void: trade /= Void
			trade_open: trade.is_open
		do
			opening_trade := trade
		ensure
			opening_trade_set: opening_trade = trade
			not_closed: not is_closed
		end

feature -- Access

	opening_trade: TRADE
			-- Opening trade of the match

	closing_trade: TRADE
			-- Closing trade that matches the `opening_trade'

	name: STRING
			-- Name of the traded item

	symbol: STRING is
			-- Symbol of the traded item
		do
			Result := opening_trade.symbol
		end

	start_date: DATE is
			-- Date the trade was entered
		do
			Result := opening_trade.date
		ensure
			Result = opening_trade.date
		end

	end_date: DATE is
			-- Date the trade was closed
		do
			if closing_trade /= Void then
				Result := closing_trade.date
			end
		ensure
			is_closed implies Result = closing_trade.date
		end

	short: BOOLEAN is
			-- Is this a short trade?
		do
			Result := opening_trade.is_sell
		end

	is_closed: BOOLEAN is
			-- Has the trade been closed?
		do
			Result := closing_trade /= Void
		end

	partial: BOOLEAN is
			-- Have not all units of the opening trade been closed?
		do
			Result := is_closed and units < opening_trade.units
		ensure
			Result = is_closed and units < opening_trade.units
		end

	units: INTEGER is
			-- Number of units traded
		do
			if is_closed then
				Result := closing_trade.units
			else
				Result := opening_trade.units
			end
		ensure
			close_units_when_closed:
				is_closed implies Result = closing_trade.units
			open_units_when_not_closed:
				not is_closed implies Result = opening_trade.units
		end

	buy_price: REAL is
			-- Buy price, per unit
		do
			if short then
				Result := closing_price
			else
				Result := opening_price
			end
		end

	sell_price: REAL is
			-- Sell price, per unit
		do
			if short then
				Result := opening_price
			else
				Result := closing_price
			end
		end

	opening_price: REAL is
			-- Price per unit at which the trade opened
		do
			Result := opening_trade.price
		end

	closing_price: REAL is
			-- Price per unit at which the trade closed
		do
			Result := last_price
		end

	last_price: REAL is
			-- Last price, per unit
		do
			if is_closed then
				Result := closing_trade.price
			else
				Result := last_price_field
			end
		end

	balance_per_unit: REAL is
			-- Amount made or lost per unit
		do
			Result := last_price - opening_price
			if short then
				Result := Result * -1
			end
		end

	balance: REAL is
			-- Amount made or lost on the trade, including commissions
		do
			Result := balance_per_unit * units - opening_trade.commission
			if closing_trade /= Void then
				Result := Result - closing_trade.commission
			end
		ensure
			result_when_closed: is_closed implies
				Result - (balance_per_unit * units -
				(opening_trade.commission + closing_trade.commission)) < epsilon
			result_when_open: not is_closed implies
				Result - (balance_per_unit * units -
				opening_trade.commission) < epsilon
		end

	percent_gain_or_loss: REAL is
			-- Percent gain or loss on the trade
		do
			Result := balance / (opening_price * units) * 100
		ensure
			pct_gain_loss:
				Result - (balance / (opening_price * units) * 100) < epsilon
		end

	report: STRING is
		local
			usymbol: STRING
		do
			create Result.make (0)
			usymbol := clone (symbol)
			usymbol.to_upper
			Result.append (usymbol)
			if name /= Void then
				Result.append (" (")
				Result.append (name); Result.append(")")
			end
			if not is_closed and short then
				Result.append (", last price: ")
				Result.append (last_price.out)
			else
				Result.append (", buy price: ")
				Result.append (buy_price.out)
			end
			if not is_closed and not short then
				Result.append (", last price: ")
				Result.append (last_price.out)
			else
				Result.append (", sell price: ")
				Result.append (sell_price.out)
			end
			if short then
				Result.append (",  Short ")
			else
				Result.append (",  Long ")
			end
			Result.append (units.out)
			Result.append (" units%Nbalance: ")
			Result.append (balance.out)
			Result.append (".  Trade opened on ")
			Result.append (start_date.out)
			if is_closed then
				Result.append (". Trade closed on ")
				Result.append (end_date.out)
				Result.append (".%N")
			else
				Result.append (". (Trade is currently open.)%N")
			end
			Result.append ("percent profit or loss: ")
			Result.append (percent_gain_or_loss.out)
			Result.append ("%N")
		end

feature -- Status setting

	set_closing_trade (trade: TRADE) is
			-- Set the exit price.
		require
			trade_not_void: trade /= Void
			symbol_valid: trade.symbol.is_equal (opening_trade.symbol)
			units_le_opening_units: trade.units <= opening_trade.units
		do
			closing_trade := trade
		ensure
			closed: is_closed
			closing_trade_set: closing_trade = trade
		end

	set_last_price (p: REAL) is
			-- Set the last price.
		require
			not_closed: not is_closed
		do
			last_price_field := p
		ensure
			set: rabs (last_price - p) < epsilon
		end

feature {NONE} -- Implementation

	last_price_field: REAL

invariant

	last_price_is_buy_price_if_short:
		short implies rabs (last_price - buy_price) < epsilon
	last_price_is_sell_price_if_long:
		not short implies rabs (last_price - sell_price) < epsilon
	units_greater_than_0: units > 0
	symbol_not_void: symbol /= Void
	open_eq_sell_price_if_short:
		short implies opening_price - sell_price < epsilon
	open_eq_buy_price_if_long:
		not short implies opening_price - buy_price < epsilon
	close_eq_buy_price_if_short:
		short implies closing_price - buy_price < epsilon
	close_eq_sell_price_if_long:
		not short implies closing_price - sell_price < epsilon
	closing_pirce_equals_last_price: closing_price - last_price < epsilon
	opening_trade_not_void: opening_trade /= Void
	closed_definition: is_closed = (closing_trade /= Void)

end -- TRADE_MATCH
