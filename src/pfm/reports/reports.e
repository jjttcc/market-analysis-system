indexing
	description: "List of all reports to be executed - Use via inheritance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	REPORTS

feature {NONE} -- Initialization

	execute_reports is
			-- Execute all reports, using `open_trades' and `complete_trades'
			-- as input data.
		require
			reports_exist: contents /= Void
		do
			from
				contents.start
			until
				contents.exhausted
			loop
				if open_trades /= Void then
					contents.item.set_open_trades (open_trades)
				end
				if complete_trades /= Void then
					contents.item.set_complete_trades (complete_trades)
				end
				contents.item.execute
				contents.forth
			end
		end

feature {NONE}

	contents: LIST [REPORT]
			-- All reports to be executed

	complete_trades: LIST [TRADE_MATCH] is
			-- List of all TRADE_MATCHs
		deferred
		end

	open_trades: LIST [OPEN_TRADE] is
			-- List of all currently open trades
		deferred
		end

end -- REPORTS
