indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class INDICATOR_LIST_REQUEST_CMD inherit

	DATA_REQUEST_CMD

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			ilist: LIST [MARKET_FUNCTION]
			fields: LIST [STRING]
		do
			target := msg
			fields := tokens (input_field_separator)
			if fields.count /= 2 then
				report_error (Error, <<"Wrong number of fields.">>)
			else
				parse_symbol_and_period_type (1, 2, fields)
				if not parse_error then
					send_response
				end
			end
		end

	send_response is
			-- Obtain the indicator list corresponding to `market_symbol' and
			-- `trading_period_type' and send it to the client.
		local
			tradable: TRADABLE [BASIC_MARKET_TUPLE]
			ilist: LIST [MARKET_FUNCTION]
		do
			tradable := tradables.tradable (market_symbol,
				trading_period_type)
			if tradable = Void then
				if not tradables.symbols.has (market_symbol) then
					report_error (Invalid_symbol, <<"Symbol not in database.">>)
				elseif server_error then
					report_server_error
				else
					report_error (Error, <<"Invalid period type">>)
				end
			else
				send_ok
				ilist := tradable.indicators
				from
					ilist.start
				until
					ilist.islast
				loop
					print (ilist.item.name)
					print (Output_record_separator)
					ilist.forth
				end
				print (ilist.last.name)
				print (eom)
			end
		end

end -- class INDICATOR_LIST_REQUEST_CMD
