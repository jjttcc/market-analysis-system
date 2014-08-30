note
    description: "Commands that respond to a request for the changeable %
        %parameters for a specified indicator"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class INDICATOR_PARAMETERS_REQUEST_CMD inherit
    TRADABLE_REQUEST_COMMAND
        rename
            set_name as set_command_name, name as command_name
        end

inherit {NONE}
    STRING_UTILITIES
        rename
            make as su_make_unused
        export
            {NONE} all
        end

creation

    make

feature -- Access

    expected_field_count: INTEGER = 1

feature -- Basic operations

    do_execute(message: ANY)
        local
            msg: STRING
            fields: LIST [STRING]
        do
            msg := message.out
            parse_error := False
            target := msg -- set up for tokenization
            fields := tokens(message_component_separator)
            if fields.count < expected_field_count then
                report_error(Error, <<"Fields count wrong for ", name, ".">>)
                parse_error := True
            end
            if not parse_error then
                indicator_name := fields @ 1
                retrieve_parameters
                send_response
            end
        end

feature {NONE} -- Implementation

    indicator_name: STRING
            -- Name of the indicator for which parameters are to be retrieved

    parse_error: BOOLEAN
            -- Did a parse error occur?

    parameters: LIST [FUNCTION_PARAMETER]

feature {NONE}

    retrieve_parameters
        require
            ind_name_set: indicator_name /= Void
        local
            i: MARKET_FUNCTION
        do
            i := tradables.indicator_with_name(indicator_name)
            parameters := session.parameters_for_indicator(i)
        ensure
            parameters_set: parameters /= Void
        end

    send_response
            -- Run market analysis on for `symbol' for all event types
            -- specified in `requested_event_types' between
            -- `analysis_start_date' and `analysis_end_date'.
        require
            settings_not_void: parameters /= Void
        local
            response: STRING
        do
            --fill/format 'response' from 'parameters'
            put_ok
            send_parameter_report
            put(eom)
        end

    iteration: INTEGER

    send_parameter_report
            -- Send the report, from `parameters', to the client.
        require
            parameters_set: parameters /= Void
        do
            iteration := 1
            parameters.do_all(agent (param: FUNCTION_PARAMETER)
                do
                    put(concatenation(<<param.unique_name,
                        message_component_separator, param.current_value,
                        message_component_separator,
                        param.value_type_description>>))
                    if iteration < parameters.count then
                        put(message_record_separator)
                    end
                    iteration := iteration + 1
                end
                (?))
        end

    name: STRING = "Indicator parameters request"

end
