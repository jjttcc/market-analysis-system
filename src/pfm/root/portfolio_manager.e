indexing
	description: "Root class for the Portfolio Management System"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class PORTFOLIO_MANAGER inherit

	GENERAL_UTILITIES

creation

	make

feature {NONE} -- Initialization

	make is
		local
			trades: LIST [TRADE_MATCH]
			otrades: LIST [OPEN_TRADE]
			total_gain: REAL
			set_up: SETUP
			trade: TRADE
		do
			create set_up.make
			trades := set_up.tradelist
			otrades := set_up.open_trades
			from
				trades.start
			until
				trades.exhausted
			loop
				print (trades.item.report)
				print ("%N")
				total_gain := total_gain + trades.item.balance
				trades.forth
			end
			print ("Total profit or loss: ")
			print (total_gain.out)
			print ("%NTrades still open:%N")
			from
				otrades.start
			until
				otrades.exhausted
			loop
				trade := otrades.item.trade
				print (concatenation (<<"symbol: ", trade.symbol,
					", shares: ", otrades.item.open_units, ", date: ",
					trade.date>>))
				if trade.is_sell then
					print (" (short sale)")
				end
				print ("%N")
				otrades.forth
			end
		end

end -- PORTFOLIO_MANAGER
