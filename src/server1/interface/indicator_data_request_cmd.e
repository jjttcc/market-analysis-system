indexing
	description:
		"A command that responds to a client request for indicator data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INDICATOR_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		redefine
			error_context, send_response_for_tradable, parse_remainder,
			additional_field_constraints_fulfilled,
			additional_field_constraints_msg
		end


creation

	make

feature {NONE} -- Hook routine implementations

	expected_field_count: INTEGER is 3

	symbol_index: INTEGER is 2

	period_type_index: INTEGER is 3

	additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN is
		do
			Result := fields.first.is_integer
		end

	send_response_for_tradable (t: TRADABLE [BASIC_MARKET_TUPLE]) is
		local
			indicator: MARKET_FUNCTION
		do
			if
				indicator_id < 1 or indicator_id > t.indicators.count
			then
				report_error (Error, <<invalid_indicator_id_msg>>)
			else
				t.set_target_period_type (trading_period_type)
				indicator := t.indicators @ indicator_id
				if not indicator.processed then
					indicator.process
				end
				set_print_parameters
				set_preface (ok_string)
				set_appendix (eom)
				print_indicator (indicator)
			end
		end

	parse_remainder (fields: LIST [STRING]) is
		do
			indicator_id := fields.first.to_integer
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<error_context_prefix, market_symbol>>)
		end

	additional_field_constraints_msg: STRING is "Indicator ID is not an integer"

feature {NONE} -- Implementation

	indicator_id: INTEGER
			-- ID of the indicator requested by the user

	invalid_indicator_id_msg: STRING is "Invalid indicator ID"

	error_context_prefix: STRING is "retrieving indicator data for "

end -- class INDICATOR_DATA_REQUEST_CMD
