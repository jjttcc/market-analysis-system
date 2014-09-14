note
    description: "A command that responds to an event-data request - a %
        %request for trading signals for a particular tradable"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class EVENT_DATA_REQUEST_CMD inherit

    TRADABLE_REQUEST_COMMAND
        rename
            make as trc_make, set_name as set_command_name,
            name as command_name
        redefine
            error_context
        end

    DATE_PARSING_UTILITIES
        export
            {NONE} all
        end

    STRING_UTILITIES
        rename
            make as su_make_unused
        export
            {NONE} all
        end

    EVENT_REGISTRANT_WITH_CACHE
        rename
            make as mer_make
        export
            {NONE} all
            {ANY} is_interested_in
        redefine
            event_cache, notify
        end

    PERIOD_TYPE_FACILITIES
        export
            {NONE} all
        end

    GLOBAL_APPLICATION
        export
            {NONE} all
        end

creation

    make

feature {NONE} -- Initialization

    make (dispenser: TRADABLE_DISPENSER)
        do
            trc_make (dispenser)
            mer_make
        end

feature -- Basic operations

    do_execute (message: ANY)
        local
            msg: STRING
            fields: LIST [STRING]
            d: DATE
        do
            msg := message.out
            parse_error := False
            target := msg -- set up for tokenization
            fields := tokens (message_component_separator)
            if fields.count < 4 then
                report_error (Error, <<"Fields count wrong for ",
                    "trading-signal event request.">>)
                parse_error := True
            end
            if not parse_error then
                symbol := fields @ 1
                d := date_from_string (fields @ 2)
                if d = Void then
                    report_error (Error, <<"Invalid start-date specification %
                        %for trading signals request: ", fields @ 2,
                        " (format: " + date_format + ")">>)
                    parse_error := True
                else
                    create analysis_start_date.make_by_date (d)
                end
            end
            if not parse_error then
                d := date_from_string (fields @ 3)
                if d = Void then
                    report_error (Error, <<"Invalid end-date specification %
                        %for trading signals request: ", fields @ 3,
                        " (format: " + date_format + ")">>)
                    parse_error := True
                else
                    if (fields @ 3).is_equal (Now) then
                        -- Set "now" date to 2 years in the future.
                        --@@@(Check if this is needed here.)
                        d := future_date
                    end
                    create analysis_end_date.make_by_date (d)
                end
            end
            if not parse_error then
                create_event_types (fields)
            end
            if not parse_error then
                send_response
            end
        end

    notify (e: TYPED_EVENT)
        do
            if attached {TRADABLE_EVENT} e as mktev then
                event_cache.extend (mktev)
            end
        end

feature {NONE} -- Implementation

    symbol: STRING
            -- Symbol for the tradable to be processed

    analysis_start_date: DATE_TIME
            -- Start date for event processing

    analysis_end_date: DATE_TIME
            -- End date for event processing

    requested_event_types: HASH_TABLE [INTEGER, INTEGER]
            -- Event types to be processed

    parse_error: BOOLEAN
            -- Did a parse error occur?

    event_coordinator: TRADABLE_EVENT_COORDINATOR
            -- Coordinator for events to be processed

    tradable_pair: PAIR [TRADABLE [BASIC_TRADABLE_TUPLE],
        TRADABLE [BASIC_TRADABLE_TUPLE]]
            -- Intraday and non-intraday tradables for `symbol'

    event_dispatcher: EVENT_DISPATCHER

    event_cache: PART_SORTED_TWO_WAY_LIST [TRADABLE_EVENT]

feature {NONE}

    create_event_types (fields: LIST [STRING])
            -- Create `requested_event_types' from fields[4 .. fields.count].
        local
            i, id: INTEGER
            f: STRING
        do
            create requested_event_types.make (fields.count - 3)
            from i := 4 until i > fields.count or parse_error loop
                f := fields @ i
                if not f.is_integer then
                    report_error (Error, <<"Invalid event ID ",
                        "for trading signals request - non-integer: ", f>>)
                    parse_error := True
                else
                    id := f.to_integer
                    requested_event_types.put (id, id)
                end
                i := i + 1
            end
        end

    send_response
            -- Run market analysis on for `symbol' for all event types
            -- specified in `requested_event_types' between
            -- `analysis_start_date' and `analysis_end_date'.
        require
            settings_not_void: analysis_start_date /= Void and
                analysis_end_date /= Void and symbol /= Void and
                requested_event_types /= Void
        do
            initialize_event_coordinator
            if server_error then
                report_server_error
            elseif
                event_coordinator.event_generators = Void or
                event_coordinator.event_generators.is_empty
            then
                if
                    tradable_pair.left = Void and tradable_pair.right = Void
                then
                    if not tradables.symbols.has (symbol) then
                        report_error (Invalid_symbol, <<"Symbol '",
                            symbol, "' not in database.">>)
                    else
                        report_error (Error, <<"No data found for symbol ",
                            symbol>>)
                    end
                else
                    report_error (warning_string,
                        <<"No requested trading signal % %types were valid">>)
                end
            else
                put_ok
                -- Make sure current parameter settings are used:
                event_coordinator.event_generators.do_all(agent(
                    proc: TRADABLE_EVENT_GENERATOR)
                        do session.prepare_processor(proc) end
                    (?))
                event_coordinator.execute
                put (eom)
            end
        end

    perform_notify
        local
            dt_util: expanded DATE_TIME_SERVICES
        do
            check
                events_sorted: event_cache.sorted
            end
            if not event_cache.is_empty then
                from
                    event_cache.start
                until
                    event_cache.islast
                loop
                    put (concatenation (<<
                        dt_util.formatted_date (event_cache.item.date,
                            'y', 'm', 'd', ""),
                        message_component_separator,
                        dt_util.formatted_time (event_cache.item.time,
                            'h', 'm', 's', ""),
                        message_component_separator,
                        event_cache.item.type.id,
                        message_component_separator,
                        event_cache.item.type_abbreviation,
                        message_record_separator>>))
                    event_cache.forth
                end
                put (concatenation (<<
                    dt_util.formatted_date (event_cache.item.date,
                        'y', 'm', 'd', ""),
                    message_component_separator,
                    dt_util.formatted_time (event_cache.item.time,
                        'h', 'm', 's', ""),
                    message_component_separator,
                    event_cache.item.type.id,
                    message_component_separator,
                    event_cache.item.type_abbreviation>>))
            end
        end

    initialize_event_coordinator
        do
            --Create an event coordinator that only operates on the tradable
            --for `symbol'; initialize the dispatcher, event generators
            --(according to requested_event_types), etc.
            tradable_pair := pair_for_current_symbol
            if event_coordinator = Void then
                create event_dispatcher.make
                event_dispatcher.register (Current)
                create event_coordinator.make (tradable_pair)
                event_coordinator.set_dispatcher (event_dispatcher)
            else
                event_coordinator.make (tradable_pair)
            end
            -- event generators and coordinators currently don't use an
            -- end date, so just set the start date.
            event_coordinator.set_start_date_time (analysis_start_date)
            event_coordinator.set_event_generators (valid_event_generators)
        ensure
            pair_not_void: tradable_pair /= Void
        end

    valid_event_generators: LINKED_LIST [TRADABLE_EVENT_GENERATOR]
            -- Event generators specified in `requested_event_types' that
            -- are valid for `tradable_pair'
        require
            pair_set: tradable_pair /= Void
        local
            l: LIST [TRADABLE_EVENT_GENERATOR]
            t: TRADABLE [BASIC_TRADABLE_TUPLE]
        do
            create Result.make
            t := tradable_pair.right
            if t = Void then
                t := tradable_pair.left
            end
            if t /= Void then
                from
                    l := tradable_event_generation_library
                    if not t.has_open_interest then
                        -- Only tradable-event generators for stocks are valid.
                        l := stock_tradable_event_generation_library
                    end
                    l.start
                until
                    l.exhausted
                loop
                    if
                        requested_event_types.has (l.item.event_type.id)
                    then
                        Result.extend (l.item)
                    end
                    l.forth
                end
            end
        end

    pair_for_current_symbol: PAIR [TRADABLE [BASIC_TRADABLE_TUPLE],
            TRADABLE [BASIC_TRADABLE_TUPLE]]
        do
            create Result.make (tradables.tradable (symbol,
                --@@@Check if 'update' (False) should be true:
                period_types @ (period_type_names @ Hourly), False),
                tradables.tradable (symbol,
                --@@@Check if 'update' (False) should be true:
                period_types @ (period_type_names @ Daily), False))
        ensure
            not_void: Result /= Void
        end

    error_context (msg: STRING): STRING
        do
            Result := concatenation (<<"running market analysis for ",
                symbol>>)
        end

    name: STRING = "Event-data request command"

    date_format: STRING
        once
            Result := "yyyy" + date_field_separator + "mm" +
                date_field_separator + "dd"
        end

end -- class EVENT_DATA_REQUEST_CMD
