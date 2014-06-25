note
	description: "List of all reports to be executed - Use via inheritance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	REPORTS

feature {NONE} -- Initialization

	execute_reports
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

	complete_trades: LIST [TRADE_MATCH]
			-- List of all TRADE_MATCHs
		deferred
		end

	open_trades: LIST [OPEN_TRADE]
			-- List of all currently open trades
		deferred
		end

end -- REPORTS
