indexing
	description: "Root class for the Portfolio Management System"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class PORTFOLIO_MANAGER inherit

creation

	make

feature {NONE} -- Initialization

	make is
		local
			trades: LIST [TRADE_MATCH]
			total_gain: REAL
			set_up: SETUP
		do
			create set_up.make
			trades := set_up.tradelist
			from
				trades.start
			until
				trades.exhausted
			loop
				print (trades.item.out)
				print ("%N")
				total_gain := total_gain + trades.item.balance
				trades.forth
			end
			print ("Total profit or loss: ")
			print (total_gain.out)
			print ("%N")
		end

feature {NONE} -- Implmenetation

	tradelist: LIST [TRADE_MATCH] is
		local
			trade: TRADE_MATCH
			odate, close_date: DATE
		do
			create {LINKED_LIST [TRADE_MATCH]} Result.make
			create close_date.make (2000, 4, 25)

			create odate.make (2000, 4, 18)
			create trade.make (Void, "BK", odate, 41.4375, 119, false)
			trade.set_last_price (44.4375)
			Result.force (trade)

			create odate.make (2000, 4, 19)
			create trade.make (Void, "CGP", odate, 47.4375, 105, false)
			trade.set_last_price (49.75)
			Result.force (trade)

			create odate.make (2000, 4, 20)
			create trade.make (Void, "GBLX", odate, 29.25, 124, true)
			trade.close (28.125, close_date)
			Result.force (trade)

			create odate.make (2000, 4, 24)
			create trade.make (Void, "NCE", odate, 32, 155, false)
			trade.set_last_price (33.75)
			Result.force (trade)

			create odate.make (2000, 4, 20)
			create trade.make (Void, "NTAP", odate, 57.25, 47, true)
			trade.close (58.5, close_date)
			Result.force (trade)

			create odate.make (2000, 4, 20)
			create trade.make (Void, "ORCT", odate, 39, 74, true)
			trade.set_last_price (40)
			Result.force (trade)

			create odate.make (2000, 4, 19)
			create trade.make (Void, "PTEN", odate, 26, 121, false)
			trade.set_last_price (26.625)
			Result.force (trade)
		ensure
			Result /= Void
		end

end -- PORTFOLIO_MANAGER
