indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class INDICATOR_DATA_REQUEST_CMD inherit

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
			if fields.count /= 3 or not fields.first.is_integer then
				report_error (Error, <<"Wrong number of fields.">>)
			else
				parse_symbol_and_period_type (2, 3, fields)
				if not parse_error then
					indicatorID := fields.first.to_integer
					send_response
				end
			end
		end

feature {NONE}

	indicatorID: INTEGER
			-- ID of the indicator requested by the user

	send_response is
			-- Obtain the market corresponding to `market_symbol' and
			-- dispatch the data for the indicator specified by
			-- `indicatorID' for that market for `trading_period_type'
			-- to the client.
		require
			tpt_ms_not_void:
				trading_period_type /= Void and market_symbol /= Void
			-- indicatorID is valid
		local
			indicator: MARKET_FUNCTION
			market: TRADABLE [BASIC_MARKET_TUPLE]
		do
			market := tradables.tradable (market_symbol,
				trading_period_type)
			if market = Void then
				if not tradables.symbols.has (market_symbol) then
					report_error (Invalid_symbol, <<"Symbol not in database.">>)
				elseif server_error then
					report_server_error
				else
					report_error (Error, <<"Invalid period type">>)
				end
			elseif
				indicatorID < 1 or indicatorID > market.indicators.count
			then
				report_error (Error, <<"Invalid indicator ID">>)
			else
				market.set_target_period_type (trading_period_type)
				indicator := market.indicators @ indicatorID
				if not indicator.processed then
					indicator.process
				end
				set_print_parameters
				send_ok
				print_indicator (indicator)
				print (eom)
			end
		end

end -- class INDICATOR_DATA_REQUEST_CMD
