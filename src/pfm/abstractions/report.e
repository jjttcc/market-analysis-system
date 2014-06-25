note
	description: "A portfolio report"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	REPORT

feature -- Access

	complete_trades: LIST [TRADE_MATCH]
			-- List of all "matched" trades to be used in the report

	open_trades: LIST [OPEN_TRADE]
			-- List of all currently open trades to be used in the report

feature -- Status setting

	set_complete_trades (arg: LIST [TRADE_MATCH])
			-- Set complete_trades to `arg'.
		require
			arg_not_void: arg /= Void
		do
			complete_trades := arg
		ensure
			complete_trades_set: complete_trades = arg and
				complete_trades /= Void
		end

	set_open_trades (arg: LIST [OPEN_TRADE])
			-- Set open_trades to `arg'.
		require
			arg_not_void: arg /= Void
		do
			open_trades := arg
		ensure
			open_trades_set: open_trades = arg and open_trades /= Void
		end

feature -- Basic operations

	execute
			-- Execute the report.
		deferred
		end

end -- REPORT
