indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class MARKET_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD

creation

	make

feature -- Basic operations

	do_execute (msg: STRING) is
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
			t: TRADABLE [BASIC_MARKET_TUPLE]
			pref: STRING
		do
			pref := ok_string
			if session.caching_on then
				t := cached_tradable (market_symbol, trading_period_type)
				if
					t /= Void and t.period_types.has (trading_period_type.name)
				then
					tuple_list := t.tuple_list (trading_period_type.name)
				end
				if t.has_open_interest then
					pref := concatenation(<<clone(pref), Open_interest_flag>>)
				end
			elseif
				tradables.valid_period_type (market_symbol,
					trading_period_type)
			then
				tuple_list := tradables.tuple_list (market_symbol,
					trading_period_type)
				if tradables.last_tradable.has_open_interest then
					pref := concatenation(<<clone(pref), Open_interest_flag>>)
				end
				session.set_last_tradable (tradables.last_tradable)
			end
			if tuple_list = Void then
				if not tradables.symbols.has (market_symbol) then
					report_error (Invalid_symbol, <<"Symbol '", market_symbol,
						"' not in database.">>)
				elseif server_error then
					report_server_error
				else
					report_error (Error, <<"Invalid period type: ",
						trading_period_type>>)
				end
			else
				set_print_parameters
				-- Ensure ok string is printed first.
				set_preface (pref)
				-- Ensure end-of-message string is printed last.
				set_appendix (eom)
				print_tuples (tuple_list)
			end
		end

end -- class MARKET_DATA_REQUEST_CMD
