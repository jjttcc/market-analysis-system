indexing
	description:
		"A command that responds to a client request for indicator data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INDICATOR_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		redefine
			error_context
		end


creation

	make

feature -- Basic operations

	do_execute (msg: STRING) is
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
			-- Obtain the tradable corresponding to `market_symbol' and
			-- dispatch the data for the indicator specified by
			-- `indicatorID' for that tradable for `trading_period_type'
			-- to the client.
		require
			tpt_ms_not_void:
				trading_period_type /= Void and market_symbol /= Void
		local
			indicator: MARKET_FUNCTION
			tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			tradable := cached_tradable (market_symbol, trading_period_type)
			if tradable = Void then
				if server_error then
					report_server_error
				elseif not tradables.symbols.has (market_symbol) then
					report_error (Invalid_symbol, <<"Symbol not in database.">>)
				else
					report_error (Error, <<"Invalid period type">>)
				end
			elseif
				indicatorID < 1 or indicatorID > tradable.indicators.count
			then
				report_error (Error, <<"Invalid indicator ID">>)
			else
				tradable.set_target_period_type (trading_period_type)
				indicator := tradable.indicators @ indicatorID
				if not indicator.processed then
					indicator.process
				end
				set_print_parameters
				set_preface (ok_string)
				set_appendix (eom)
				print_indicator (indicator)
			end
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<"retrieving indicator data for ",
				market_symbol>>)
		end

end -- class INDICATOR_DATA_REQUEST_CMD
