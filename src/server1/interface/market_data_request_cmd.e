indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
				report_error (Error, <<"Fields count wrong.">>)
			else
				parse_symbol_and_period_type (1, 2, fields)
				if not parse_error then
					send_response
				end
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
		local
			tuple_list: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]
		do
			tuple_list := tradables.tuple_list (market_symbol,
				trading_period_type)
			if tuple_list = Void then
				if not tradables.symbols.has (market_symbol) then
					report_error (Invalid_symbol, <<"Symbol not in database.">>)
				elseif server_error then
					report_server_error
				else
					report_error (Error, <<"Invalid period type.">>)
				end
			else
				set_print_parameters
				send_ok
				print_tuples (tuple_list)
				print (eom)
			end
		end

end -- class MARKET_DATA_REQUEST_CMD
