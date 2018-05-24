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
    -- <ind-name>\t[per-type\t]<param-idx1>:<value1>,<param-idx2>:<value2>,...
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
                set_tradable_processor
                if tradable_processor /= Void then
                    retrieve_parameters
                    if not parse_error then
                        if modify_parameters then
                            process_parameter_specs(fields)
                        end
                        send_response
                    else
                        report_error(Error, <<error_msg>>)
                    end
                else
                    report_error(invalid_object_name, <<invalid_obj_msg>>)
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
            -- The name of `tradable_processor'

    tradable_processor: TRADABLE_PROCESSOR
            -- The processor for which parameters are to be retrieved

    parse_error: BOOLEAN
            -- Did a parse error occur?

    parameters: LIST [FUNCTION_PARAMETER]

    error_msg: STRING

    expected_field_count: INTEGER
        do
            if modify_parameters then
                if requires_period_type then
                    Result := 3
                else
                    Result := 2
                end
            else
                Result := 1
            end
        end

    default_param_specs_index: INTEGER = 2

    period_type_index: INTEGER = 2

feature {NONE} -- Hook routines

    requires_period_type: BOOLEAN
            -- Does this parameter-based command require a period type?
        do
            Result := False
        end

    set_period_type(pertype: STRING)
            -- Set the period-type (name) attribute (in descendant class).
            -- If `pertype' is invalid, set parse_error to true and
            -- `error_msg' to a description of the error.
        require
            need_pertype: requires_period_type
        do
        end

feature {PARAMETER_BASED_REQUEST_CMD} -- Implementation

    iteration: INTEGER
        once
            Result := -1
        end

    set_iteration(i: INTEGER)
        do
        end

    invalid_obj_msg: STRING
        do
            Result := "Invalid " + object_type + " name: " +
                tradable_processor_name
        end

feature {NONE} -- Hook methods

    object_type: STRING
            -- The type of `tradable_processor'
        deferred
        end

feature {NONE}

    retrieve_parameters
        require
            proc_set: tradable_processor /= Void
        deferred
        ensure
            parameters_set: parameters /= Void
        end

    set_tradable_processor
        require
            proc_name_set: tradable_processor_name /= Void
        deferred
        end

    process_parameter_specs(fields: LIST [STRING])
        require
            has_params: fields.count >= default_param_specs_index
        local
            param_specs, param_spec: LIST [STRING]
            param_index, parmspecs_index: INTEGER
        do
            parmspecs_index := default_param_specs_index
            if requires_period_type then
                set_period_type(fields[period_type_index])
                parmspecs_index := parmspecs_index + 1
            end
            if not parse_error then
                target := fields[parmspecs_index]
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
                                param_spec[1] + " [1.." +
                                parameters.count.out + "]"
                        end
                    else
                        parse_error := True
                        error_msg := "id/index field is not an integer: " +
                            param_spec[1]
                    end
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
                    put(concatenation(<<param.verbose_name,
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
