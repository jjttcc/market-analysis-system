indexing
	description: "Basic portfolio status report"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class BASIC_REPORT inherit

	REPORT

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is do end

feature -- Basic operations

	execute is
		local
			total_gain: REAL
			trade: TRADE
		do
			if complete_trades /= Void then
				from
					complete_trades.start
				until
					complete_trades.exhausted
				loop
					print (complete_trades.item.report)
					print ("%N")
					total_gain := total_gain + complete_trades.item.balance
					complete_trades.forth
				end
				print ("Total profit or loss: ")
				print (total_gain.out)
			end
			if open_trades /= Void then
				print ("%NTrades still open:%N")
				from
					open_trades.start
				until
					open_trades.exhausted
				loop
					trade := open_trades.item.trade
					print (concatenation (<<"symbol: ", trade.symbol,
						", shares: ", open_trades.item.open_units, ", date: ",
						trade.date>>))
					if trade.is_sell then
						print (" (short sale)")
					end
					print ("%N")
					open_trades.forth
				end
			end
		end

end -- BASIC_REPORT
