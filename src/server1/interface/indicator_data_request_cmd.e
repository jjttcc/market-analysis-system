indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class INDICATOR_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD

feature -- Basic operations

	execute (msg: STRING) is
		require
			market_list.item /= Void
		local
			fields: ARRAY [STRING]
			pt_name: STRING
		do
			target := msg
			fields := target.tokens (field_separator)
			-- Expected contents of `msg':
			-- indicatorID and trading_period_type
			if fields.count /= 3 or not fields.item (1).is_integer then
				report_error (<<"fields count wrong ...">>)
			else
				indicatorID := fields.item (1).to_integer
				pt_name := fields @ 2
				if not period_type_names.has (pt_name) then
					report_error (<<"...">>)
				else
					trading_period_type := period_types @ pt_name
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
			data: STRING
			indicator: MARKET_FUNCTION
			market: TRADABLE
		do
			market := market_list.item
			market.set_trading_period_type (trading_period_type)
			indicator := market.indicators @ indicatorID
			if not indicator.processed then
				indicator.process
			end
			data := formatted_results (indicator)
			active_medium.put_string (data)
		end

end -- class INDICATOR_DATA_REQUEST_CMD
