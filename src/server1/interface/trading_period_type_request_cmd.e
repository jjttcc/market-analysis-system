indexing
	description:
		"A command that responds to a GUI client request for a list of all %
		%trading period types valid for a specified market"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADING_PERIOD_TYPE_REQUEST_CMD inherit

	REQUEST_COMMAND

	GLOBAL_SERVICES
		export
			{NONE} all
		undefine
			print
		end

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		do
			-- `msg' is expected to contain (only) the market symbol
			market_list.search_by_symbol (msg)
			if market_list.off then
				report_error (<<"Symbol not in database">>)
			else
				send_ok
				-- Since only daily and weekly trading period types are
				-- allowed in the current version (for all markets), the
				-- response is simply hard-coded here.  This will probably
				-- change in the future.
				print_list (<<period_type_names @ Daily, 
							Output_record_separator,
							period_type_names @ Weekly>>)
				print (eom)
			end
		end

end -- class TRADING_PERIOD_TYPE_REQUEST_CMD
