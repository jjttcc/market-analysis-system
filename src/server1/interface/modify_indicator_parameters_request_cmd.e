note
    description: "Commands that respond to a request to modify a set of %
        %parameters for a specified indicator"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class MODIFY_INDICATOR_PARAMETERS_REQUEST_CMD inherit
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

    expected_field_count: INTEGER = 2

feature -- Basic operations

    do_execute(message: ANY)
        local
            msg: STRING
            fields: LIST [STRING]
        do
            msg := message.out
            -- Expected format:
            -- <ind-name>\t<param-idx1>:<value1>,<param-idx2>:<value2>,...
            parse_error := False
            target := msg -- set up for tokenization
            fields := tokens(message_component_separator)
            if fields.count < expected_field_count then
                report_error(Error, <<"Fields count wrong for ", name, ".">>)
                parse_error := True
            end
            if not parse_error then
                indicator_name := fields @ 1
                process_parameter_specs(fields)
                if not parse_error then
                    send_response
                else
                    report_error(Error, <<error_msg>>)
                end
            end
        end

feature {NONE} -- Implementation

    indicator_name: STRING
            -- Name of the indicator for which parameters are to be retrieved

    parse_error: BOOLEAN
            -- Did a parse error occur?

    error_msg: STRING

    parameters: LIST [FUNCTION_PARAMETER]

feature {NONE}

    process_parameter_specs(fields: LIST [STRING])
        require
            ind_name_set: indicator_name /= Void
            has_params: fields.count >= param_specs_index
        local
            ind: MARKET_FUNCTION
            param_specs, param_spec: LIST [STRING]
            param_index: INTEGER
        do
            ind := tradables.indicator_with_name(indicator_name)
            parameters := session.parameters_for_indicator(ind)
            target := fields[param_specs_index]
            param_specs := tokens(message_sub_field_separator)
            across param_specs as spec loop
                target := spec.item
                param_spec := tokens(message_key_value_separator)
                if param_spec[1].is_integer then
                    param_index := param_spec[1].to_integer
                    if parameters.valid_index(param_index) then
                        parameters[param_index].change_value(param_spec[2])
                    else
                        parse_error := True
                        error_msg := "id/index field is out of range: " +
                            param_spec[1] + " [1.." + parameters.count.out + "]"
                    end
                else
                    parse_error := True
                    error_msg := "id/index field is not an integer: " +
                        param_spec[1]
                end
            end
        ensure
            parameters_set: parameters /= Void
        end

    send_response
            -- Run market analysis on for `symbol' for all event types
            -- specified in `requested_event_types' between
            -- `analysis_start_date' and `analysis_end_date'.
        require
            settings_not_void: parameters /= Void
        do
            put_ok
            --!!!!Send what here? Anything?!!!!!!!
            put(eom)
        end

    name: STRING = "Indicator parameters set request"

    param_specs_index: INTEGER = 2

end
