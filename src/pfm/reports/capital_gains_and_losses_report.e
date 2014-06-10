note
	description: "Captital gains and losses report suitable for attaching %
		%to Schedule D of the U.S. federal tax form - up-to-date as of %
		%April 15, 2000"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CAPITAL_GAINS_AND_LOSSES_REPORT inherit

	REPORT

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make do end

feature -- Basic operations

	execute
		local
			total, total_sales, buy_price, sell_price: DOUBLE
			trade: TRADE
			t: TRADE_MATCH
		do
			print_header
			if complete_trades /= Void then
				from
					complete_trades.start
					total_sales := 0; total := 0
				until
					complete_trades.exhausted
				loop
					if complete_trades.item.is_closed then
						t := complete_trades.item
						buy_price := t.buy_price * t.units - t.buy_commission
						sell_price := t.sell_price * t.units - t.sell_commission
						report_trade (t, buy_price, sell_price)
						total := total + t.balance
						total_sales := total_sales + sell_price
						complete_trades.forth
					end
				end
				print_list (<<"%NTotal Sales: ", formatted_price (
					total_sales, 12, false), ",  Total Gain or Loss: ",
					formatted_price (total, 12, false), "%N">>)
			end
		end

feature {NONE} -- Initialization

	print_header
			-- Print the schedule D report header
		local
			line: STRING
		do
			print ("                  Short Term Capital Gains and Losses%N%N")
			print ("Desc.      Date acquired  Date sold  Sales price%
				%  Cost or       Gain or (loss)%N")
			print ("                                                %
				%  other basis                  %N")
			create line.make (79)
			line.fill_character ('-')
			print_list (<<line, "%N">>)
		end

	right_pad (s: STRING; count: INTEGER)
			-- Right pad `s' with blanks to ensure that it is s.count =
			-- `count'.  If s.count >= `count' no action is taken.
		require
			not_void: s /= Void
		do
			if s.count < count then
				from
				until
					s.count = count
				loop
					s.extend (' ')
				end
			end
		ensure
			padded: old s.count < count implies s.count = count
		end

	left_pad (s: STRING; count: INTEGER)
			-- Left pad `s' with blanks to ensure that it is s.count =
			-- `count'.  If s.count >= `count' no action is taken.
		require
			not_void: s /= Void
		do
			if s.count < count then
				from
				until
					s.count = count
				loop
					s.precede (' ')
				end
			end
		ensure
			padded: old s.count < count implies s.count = count
		end

	formatted_date (d: DATE): STRING
		local
			ifmt: FORMAT_INTEGER
		do
			create ifmt.make(2)
			ifmt.right_justify; ifmt.zero_fill
			Result := concatenation (<<ifmt.formatted (d.month), "-",
				ifmt.formatted (d.day), "-",
				ifmt.formatted (d.year \\ 100)>>)
		end

	strip_leading_char (s: STRING; c: CHARACTER)
			-- Strip all occurrences of `c' at the beginning of `s'
		require
			not_void: s /= Void
		do
			from
			until
				s @ 1 /= c
			loop
				s.remove (1)
			end
		end

	formatted_price (p: REAL; width: INTEGER; justify: BOOLEAN): STRING
		local
			df: FORMAT_DOUBLE
		do
			create df.make (width, 2)
			Result := df.formatted (p).out
			if not justify then
				strip_leading_char (Result, ' ')
			end
		end

	gain_or_loss (amount: REAL): STRING
			-- Amount, formatted as a gain or loss - surrounded by
			-- parentheses if a loss (negative)
		do
			if amount < 0 then
				Result := "("
			else
				Result := ""
			end
			Result.append (formatted_price (amount, 24, false))
			if amount < 0 then
				Result.append (")")
			end
		end

	report_trade (t: TRADE_MATCH; buy_price, sell_price: REAL)
			-- Output a Schedule B report on trade `t'.
		local
			line, s: STRING
		do
			s := t.symbol; s.to_upper
			line := concatenation (<<t.units.out, " ", s>>)
			right_pad (line, 11)
			-- Date acquired
			if t.short then
				-- Date acquired for a short sale is the close date.
				s := formatted_date (t.end_date)
			else
				s := formatted_date (t.start_date)
			end
			right_pad (s, 15)
			line.append (s)
			-- Date sold
			if t.short then
				-- Date sold for a short sale is the open date.
				s := formatted_date (t.start_date)
			else
				s := formatted_date (t.end_date)
			end
			right_pad (s, 11)
			line.append (s)
			s := formatted_price (sell_price, 8, true)
			right_pad (s, 13)
			line.append (s)
			s := formatted_price (buy_price, 8, true)
			right_pad (s, 14)
			line.append (s)
			s := gain_or_loss (t.balance)
			if t.balance < 0 then
				left_pad (s, 13)
			else
				left_pad (s, 12)
			end
			line.append (s)
			print_list (<<line, "%N">>)
		end

end -- CAPITAL_GAINS_AND_LOSSES_REPORT
