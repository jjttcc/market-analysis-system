note
    description: "TRADABLE_REQUEST_COMMANDs that work with FUNCTION_PARAMETERs"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class PARAMETER_BASED_REQUEST_CMD inherit
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

feature -- Basic operations

    -- Expected message format:
    -- <ind-name>\t<param-idx1>:<value1>,<param-idx2>:<value2>,...
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
                tradable_processor_name := fields @ 1
                retrieve_parameters
                if not parse_error then
                    if modify_parameters then
                        process_parameter_specs(fields)
                    end
                    send_response
                else
                    report_error(Error, <<error_msg>>)
                end
            end
        end

feature {NONE} -- Implementation

    name: STRING
        deferred
        end

    modify_parameters: BOOLEAN
            -- Are the targeted FUNCTION_PARAMETERs to be modified?
        do
            Result := False
        end

    tradable_processor_name: STRING
            -- Name of the processor for which parameters are to be retrieved

    parse_error: BOOLEAN
            -- Did a parse error occur?

    parameters: LIST [FUNCTION_PARAMETER]

    error_msg: STRING

    expected_field_count: INTEGER
        do
            if modify_parameters then
                Result := 2
            else
                Result := 1
            end
        end

    param_specs_index: INTEGER = 2

feature {PARAMETER_BASED_REQUEST_CMD} -- Implementation

    iteration: INTEGER
        once
            Result := -1
        end

    set_iteration(i: INTEGER)
        do
        end

feature {NONE}

    retrieve_parameters
        require
            proc_name_set: tradable_processor_name /= Void
        deferred
        ensure
            parameters_set: parameters /= Void
        end

    process_parameter_specs(fields: LIST [STRING])
        require
            has_params: fields.count >= param_specs_index
        local
            param_specs, param_spec: LIST [STRING]
            param_index: INTEGER
        do
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
        end

    send_response
        require
            settings_not_void: parameters /= Void
        do
            put_ok
            if not modify_parameters then
                -- (Send content only if parameters are not modified.)
                send_response_content
            end
            put(eom)
        end

    send_response_content
            -- Send the expected response message/content, if any.
        require
            parameters_set: parameters /= Void
        do
            set_iteration(1)
            parameters.do_all(agent (param: FUNCTION_PARAMETER)
                do
                    put(concatenation(<<param.unique_name,
                        message_component_separator, param.current_value,
                        message_component_separator,
                        param.value_type_description>>))
                    if iteration < parameters.count then
                        put(message_record_separator)
                    end
                    set_iteration(iteration + 1)
                end
                (?))
        end

invariant

    iteration_non_negative_if_used: not modify_parameters implies
        iteration >= 0

end