indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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
				report_error (<<"fields count wrong ...">>)
			else
				parse_symbol_and_period_type (2, 3, fields)
				indicatorID := fields.first.to_integer
				send_response
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
			market_list.search_by_symbol (market_symbol)
			if market_list.off then
				report_error (<<"Symbol not in database">>)
			else
				market := market_list.item
				if
					indicatorID < 1 or indicatorID > market.indicators.count
				then
					report_error (<<"Invalid indicator ID">>)
				else
					market.set_target_period_type (trading_period_type)
					indicator := market.indicators @ indicatorID
					if not indicator.processed then
						indicator.process
					end
					set_print_dates
					send_ok
					print_indicator (indicator)
					print (eom)
				end
			end
		end

end -- class INDICATOR_DATA_REQUEST_CMD
