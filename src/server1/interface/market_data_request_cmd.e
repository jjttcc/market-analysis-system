indexing
	description:
		"A command that responds to a client request for market data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		redefine
			error_context, create_and_send_response
		end

creation

	make

feature {NONE} -- Hook routine implementations

	expected_field_count: INTEGER is
		once
			Result := 2
		end

	symbol_index: INTEGER is
		once
			Result := 1
		end

	period_type_index: INTEGER is
		once
			Result := 2
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<error_context_prefix, market_symbol>>)
		end

feature {NONE}

	create_and_send_response is
			-- Obtain the market corresponding to `market_symbol' and
			-- dispatch the data for that market for `trading_period_type'
			-- to the client.
		local
			tuple_list: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]
			t: TRADABLE [BASIC_MARKET_TUPLE]
			pref: STRING
		do
			debug ("data_update_bug")
				print ("%N%NSending data for '" + market_symbol + "' (" +
				(create {DATE}.make_now).out + ")%N")
			end
--!!!:
print ("casr - symbol, period type: " + market_symbol + ", " +
trading_period_type.name + "%N")
			pref := ok_string
			if session.caching_on then
				t := cached_tradable (market_symbol, trading_period_type)
				if
					t /= Void and t.period_types.has (trading_period_type.name)
				then
					tuple_list := t.tuple_list (trading_period_type.name)
				end
				if t /= Void and t.has_open_interest then
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
				send_tradable_not_found_response
--!!!:
print ("tuple list was void" + "%N")
			else
print ("sending back response with tuple list of size: " +
tuple_list.count.out + "%N")
				set_print_parameters
				-- Ensure ok string is printed first.
				set_preface (pref)
				-- Ensure end-of-message string is printed last.
				set_appendix (eom)
				print_tuples (tuple_list)
			end
		end


feature {NONE} -- Implementation - constants

	error_context_prefix: STRING is "retrieving data for "

end -- class MARKET_DATA_REQUEST_CMD
