indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			fields: LIST [STRING]
		do
			target := msg -- set up for tokenization
			fields := tokens (input_field_separator)
			if fields.count /= 2 then
				report_error (Error, <<"fields count wrong ...">>)
			else
				parse_symbol_and_period_type (1, 2, fields)
				send_response
			end
		end

feature {NONE}

	send_response is
			-- Obtain the market corresponding to `market_symbol' and
			-- dispatch the data for that market for `trading_period_type'
			-- to the client.
		require
			tpt_ms_not_void:
				trading_period_type /= Void and market_symbol /= Void
		do
			if not market_list.symbols.has (market_symbol) then
				report_error (Invalid_symbol, <<"Symbol not in database">>)
			else
				market_list.search_by_symbol (market_symbol)
				set_print_parameters
				send_ok
				print_tuples (market_list.item.tuple_list (
					trading_period_type.name))
				print (eom)
			end
		end

end -- class MARKET_DATA_REQUEST_CMD
