indexing
	description: "Abstraction for a trade"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADE_MATCH inherit

	MATH_CONSTANTS
		export
			{NONE} all
			{ANY} epsilon, rabs
		undefine
			out
		end

	ANY
		redefine
			out
		end

creation

	make

feature -- Initialization

	make (nm, sym: STRING; sdate: DATE; price: REAL; u: INTEGER
			is_short: BOOLEAN) is
		require
			sym_not_void: sym /= Void
			sdate_not_void: sdate /= Void
			price_not_void: price /= Void
			u_gt_0: u > 0
		do
			symbol := sym
			name := nm
			start_date := sdate
			short := is_short
			opening_price := price
			last_price := price
			units := u
		ensure
			symbol_date_short_set: symbol = sym and start_date = sdate and
				short = is_short
			entry_price_set:
				not short implies buy_price - price < epsilon and
				short implies sell_price - price < epsilon
			not_closed: not closed
			last_price_set: last_price - price < epsilon
			open_set: opening_price - price < epsilon
			units_set: units = u
		end

feature -- Access

	name: STRING
			-- Name of the traded item

	symbol: STRING
			-- Symbol of the traded item

	start_date: DATE
			-- Date the trade was entered

	end_date: DATE
			-- Date the trade was closed

	short: BOOLEAN
			-- Is this a short trade?

	closed: BOOLEAN
			-- Has the trade been closed?

	units: INTEGER
			-- Number of units traded

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

	opening_price: REAL
			-- Price per unit at which the trade opened

	closing_price: REAL is
			-- Price per unit at which the trade closed
		do
			Result := last_price
		end

	last_price: REAL
			-- Last price, per unit

	balance_per_unit: REAL is
			-- Amount made or lost per unit
		do
			Result := last_price - opening_price
			if short then
				Result := Result * -1
			end
		end

	balance: REAL is
			-- Amount made or lost on the trade
		do
			Result := balance_per_unit * units
		end

	percent_gain_or_loss: REAL is
			-- Percent gain or loss on the trade
		do
			Result := balance_per_unit / opening_price * 100
		end

	out: STRING is
		local
			usymbol: STRING
		do
			!!Result.make (0)
			usymbol := clone (symbol)
			usymbol.to_upper
			Result.append (usymbol)
			if name /= Void then
				Result.append (" (")
				Result.append (name); Result.append(")")
			end
			if not closed and short then
				Result.append (", last price: ")
				Result.append (last_price.out)
			else
				Result.append (", buy price: ")
				Result.append (buy_price.out)
			end
			if not closed and not short then
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
			if closed then
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

	close (exit_price: REAL; close_date: DATE) is
			-- Set the exit price.
		do
			last_price := exit_price
			closed := true
			end_date := close_date
		ensure
			buy_price_set_if_short: short implies
				rabs (buy_price - exit_price) < epsilon
			sell_price_set_if_short: not short implies
				rabs (sell_price - exit_price) < epsilon
			closed: closed
			end_date_set: end_date = close_date
		end

	set_last_price (p: REAL) is
			-- Set `last_price'.
		require
			not_closed: not closed
		do
			last_price := p
		ensure
			set: rabs (last_price - p) < epsilon
		end

invariant

	last_price_is_buy_price_if_short:
		short implies rabs (last_price - buy_price) < epsilon
	last_price_is_sell_price_if_long:
		not short implies rabs (last_price - sell_price) < epsilon
	balance_when_short:
		short implies
			rabs (balance - (sell_price - last_price) * units) < epsilon
	balance_when_long:
		not short implies
			rabs (balance - (last_price - buy_price) * units) < epsilon
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

end -- TRADE_MATCH
