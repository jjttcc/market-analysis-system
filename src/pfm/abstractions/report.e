indexing
	description: "A portfolio report"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	REPORT

feature -- Access

	complete_trades: LIST [TRADE_MATCH]
			-- List of all "matched" trades to be used in the report

	open_trades: LIST [OPEN_TRADE]
			-- List of all currently open trades to be used in the report

feature -- Status setting

	set_complete_trades (arg: LIST [TRADE_MATCH]) is
			-- Set complete_trades to `arg'.
		require
			arg_not_void: arg /= Void
		do
			complete_trades := arg
		ensure
			complete_trades_set: complete_trades = arg and
				complete_trades /= Void
		end

	set_open_trades (arg: LIST [OPEN_TRADE]) is
			-- Set open_trades to `arg'.
		require
			arg_not_void: arg /= Void
		do
			open_trades := arg
		ensure
			open_trades_set: open_trades = arg and open_trades /= Void
		end

feature -- Basic operations

	execute is
			-- Execute the report.
		deferred
		end

end -- REPORT
