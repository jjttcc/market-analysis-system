note
    description:
        "A command that responds to a client request for indicator data"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

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

    expected_field_count: INTEGER
        note
            once_status: global
        once
            Result := 3
        end

    symbol_index: INTEGER = 2

    period_type_index: INTEGER = 3

    additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN
        do
            Result := fields.first.is_integer
            if not Result then
                indicator_id_not_integer_msg := indicator_id_msg_prefix +
                    fields.first + indicator_id_msg_suffix
            end
        end

    send_response_for_tradable (t: TRADABLE [BASIC_MARKET_TUPLE])
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
                session.prepare_indicator(indicator)
                if not indicator.processed then
                    indicator.process
                end
                set_print_parameters
                set_preface (ok_string)
                set_appendix (eom)
                print_indicator (indicator)
            end
        end

    parse_remainder (fields: LIST [STRING])
        do
            parse_indicator_id (fields)
        end

    error_context (msg: STRING): STRING
        do
            Result := concatenation (<<error_context_prefix, market_symbol>>)
        end

    additional_field_constraints_msg: STRING
        do
            Result := indicator_id_not_integer_msg
        end

feature {NONE} -- Implementation

    parse_indicator_id (fields: LIST [STRING])
        do
            indicator_id := fields.first.to_integer
        end

    indicator_id: INTEGER
            -- ID of the indicator requested by the user

    indicator_id_not_integer_msg: STRING

feature {NONE} -- Implementation - constants

    invalid_indicator_id_msg: STRING = "Invalid indicator ID"

    error_context_prefix: STRING = "retrieving indicator data for "

    indicator_id_msg_prefix: STRING = "Indicator ID "

    indicator_id_msg_suffix: STRING = " is not an integer"

end -- class INDICATOR_DATA_REQUEST_CMD
