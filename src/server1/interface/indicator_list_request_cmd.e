indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class INDICATOR_LIST_REQUEST_CMD inherit

	REQUEST_COMMAND

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			ilist: LIST [MARKET_FUNCTION]
		do
			-- `msg' is expected to contain (only) the market symbol
			if not market_list.symbols.has (msg) then
				report_error (Invalid_symbol, <<"Symbol not in database">>)
			else
				market_list.search_by_symbol (msg)
				send_ok
				ilist := market_list.item.indicators
				from
					ilist.start
				until
					ilist.islast
				loop
					print (ilist.item.name)
					print ("%N")
					ilist.forth
				end
				print (ilist.last.name)
				print (eom)
			end
		end

end -- class INDICATOR_LIST_REQUEST_CMD
