note
    description: "A command that responds to a client data request"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class DATA_REQUEST_CMD

inherit
    TRADABLE_REQUEST_COMMAND

    PRINTING
        rename
            output_record_separator as message_record_separator,
            output_field_separator as message_component_separator,
            output_date_field_separator as message_date_field_separator,
            output_time_field_separator as message_time_field_separator
        export
            {NONE} all
        end

inherit {NONE}
    STRING_UTILITIES
        rename
            make as su_make_unused
        export
            {NONE} all
        end

feature {NONE} -- Implementation - essential properties

    market_symbol: STRING
            -- Symbol for the selected tradable

    trading_period_type: TIME_PERIOD_TYPE
            -- Selected trading period type

feature {NONE} -- Hook routine implementations

    do_execute (message: ANY)
        local
            msg: STRING
            fields: LIST [STRING]
        do
            msg := message.out
            parse_error := False
            fields_parsed := False
            target := msg -- set up for tokenization
            fields := tokens (message_component_separator)
            if
                fields.count = expected_field_count and then
                additional_field_constraints_fulfilled (fields)
            then
                parse_fields (fields)
                if not parse_error then
                    create_and_send_response
                end
            else
                report_msg_fields_error (fields)
            end
        end

feature {NONE} -- Hook routines

    expected_field_count: INTEGER
            -- The expected field count in the argument passed to `do_execute'
        deferred
        end

    additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN
            -- Are the additional constraints, if any, for `fields' fulfilled?
        require
            fields_exists: fields /= Void
            correct_field_count: fields.count = expected_field_count
        do
            Result := True -- Yes - Redefine if needed.
        end

    additional_post_parse_constraints_fulfilled: BOOLEAN
            -- Are the additional constraints required after calling
            -- `parse_remainder', if not `parse_error', fulfilled?
        do
            Result := True -- Yes - Redefine if needed.
        end

    field_constraint_error: STRING
            -- The error message applicable when constraint checking for
            -- the fields extracted from the argument passed to `do_execute'
            -- fails
        note
            once_status: global
        once
        end

    additional_field_constraints_msg: STRING
            -- Error message for violation of the
            -- `additional_field_constraints_fulfilled' check
        note
            once_status: global
        once
            Result := "" -- Redefine if needed.
        end

    symbol_index: INTEGER
            -- Field index for the 'symbol' passed to
            -- `parse_symbol_and_period_type'
        deferred
        end

    period_type_index: INTEGER
            -- Field index for the 'period type' passed to
            -- `parse_symbol_and_period_type'
        deferred
        end

    parse_remainder (fields: LIST [STRING])
            -- Parse any remaining fields of `fields' after calling
            -- `parse_symbol_and_period_type'
        require
            no_error: not parse_error
            fields_exist: fields /= Void
            field_count_valid: fields.count = expected_field_count
            additional_constraints_hold:
                additional_field_constraints_fulfilled (fields)
        do
            do_nothing -- Redefine is something needs to be done.
        ensure
            additional_constraints_fulfilled: not parse_error implies
                additional_post_parse_constraints_fulfilled
        end

    send_response_for_tradable (t: TRADABLE [BASIC_TRADABLE_TUPLE])
            -- Use `t' to obtain the requested data and send them
            -- back to the client.
        require
            t_exists: t /= Void
        do
            do_nothing -- Redefine if action is needed.
        end

feature {NONE} -- Implementation

    parse_error: BOOLEAN
            -- Did the last call to `parse_fields' fail?

    fields_parsed: BOOLEAN
            -- Has `parse_fields' been called successfully?

    last_field_parsing_error: STRING
            -- Description of last parsing error encountered

    create_and_send_response
            -- Create the requested data and send them to the client.
        require
            fields_parsed: fields_parsed
            period_type_exists: trading_period_type /= Void
            symbol_exists: market_symbol /= Void
            additional_constraints: additional_post_parse_constraints_fulfilled
        local
            tradable: TRADABLE [BASIC_TRADABLE_TUPLE]
        do
            tradable := cached_tradable (market_symbol, trading_period_type)
            if tradable = Void then
                send_tradable_not_found_response
            else
                send_response_for_tradable (tradable)
            end
        end

feature {NONE} -- Utility

    parse_fields (fields: LIST [STRING])
        require
            fields_exist: fields /= Void
            field_count_valid: fields.count = expected_field_count
            additional_constraints_hold:
                additional_field_constraints_fulfilled (fields)
            not_parsed: not parse_error and not fields_parsed
        do
            parse_symbol_and_period_type (fields)
            if not parse_error then
                parse_remainder (fields)
                if not parse_error then
                    fields_parsed := True
                end
            end
            if parse_error then
                report_error (Error, <<last_field_parsing_error>>)
            end
        ensure
            parsed_iff_no_error: not parse_error = fields_parsed
            additional_constraints_fulfilled: not parse_error implies
                additional_post_parse_constraints_fulfilled
        end

    parse_symbol_and_period_type (fields: LIST [STRING])
            -- Extract the symbol and trading period type and place the
            -- results into `market_symbol' and `trading_period_type'.
        require
            fields_exist: fields /= Void
            field_count_valid: fields.count = expected_field_count
            additional_constraints_hold:
                additional_field_constraints_fulfilled (fields)
        local
            pt_names: ARRAY [STRING]
            pt_name: STRING
            object_comparison: BOOLEAN
        do
            pt_names := period_type_names
            object_comparison := pt_names.object_comparison
            pt_names.compare_objects
            market_symbol := fields @ symbol_index
            pt_name := fields @ period_type_index 
            if not pt_names.has (pt_name) then
                last_field_parsing_error := bad_period_type_msg
                parse_error := True
            else
                trading_period_type := period_types @ pt_name
            end
            if not object_comparison then
                pt_names.compare_references
            end
        ensure
            symbol_and_period_type_set_if_no_error: not parse_error implies
                market_symbol /= Void and trading_period_type /= Void
            fields_not_changed: fields.count = old fields.count
            field_count_still_valid: fields.count = expected_field_count
            additional_constraints_still_hold:
                additional_field_constraints_fulfilled (fields)
        end

    send_tradable_not_found_response
            -- Report to the client that the requested tradable was not found.
        require
            tpt_ms_not_void: trading_period_type /= Void and
                market_symbol /= Void
        do
            if server_error then
                report_server_error
            elseif not tradables.symbols.has (market_symbol) then
                report_error (Invalid_symbol, <<symbol_not_found_prefix,
                    market_symbol, symbol_not_found_suffix>>)
            else
                report_error (Invalid_period_type, <<invalid_period_type_prefix,
                    trading_period_type.name>>)
            end
        end

    set_print_parameters
            -- Set parameters for printing.
            -- `print_start_date' and `print_end_date' are set according to
            -- the respective settings in `session' for `trading_period';
            -- if there is no corresponding setting, the date will
            -- be set to Void.  Justification is set to off.
        do
            if session.start_dates.has (trading_period_type.name) then
                print_start_date := session.start_dates @
                    trading_period_type.name
            else
                print_start_date := Void
            end
            if session.end_dates.has (trading_period_type.name) then
                print_end_date := session.end_dates @
                    trading_period_type.name
            else
                print_end_date := Void
            end
        end

    report_msg_fields_error (fields: LIST [STRING])
        do
            if fields.count /= expected_field_count then
                report_error (Error, <<wrong_number_of_fields_msg>>)
            else
                report_error (Error, <<additional_field_constraints_msg>>)
            end
        end

feature {NONE} -- Implementation - string constants

    symbol_not_found_prefix: STRING = "Symbol "

    symbol_not_found_suffix: STRING = " not in database."

    invalid_period_type_prefix: STRING = "Invalid period type: "

    bad_period_type_msg: STRING = "Bad period type"

    wrong_number_of_fields_msg: STRING = "Wrong number of fields."

invariant

    no_error_if_fields_parsed: fields_parsed implies not parse_error
    fields_parsed_result: fields_parsed implies trading_period_type /= Void and
        market_symbol /= Void and additional_post_parse_constraints_fulfilled

end -- class DATA_REQUEST_CMD
