note
    description: "Session-specific data for MAS"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class MAS_SESSION inherit

    SESSION

creation

    make

feature {NONE} -- Initialization

    make
        do
            create start_dates.make(1)
            create end_dates.make(1)
            create params_for_proc.make(0)
            create cached_event_generators.make(0)
            caching_on := True
        ensure
            dates_not_void: start_dates /= Void and end_dates /= Void
            caching: caching_on = True
        end

feature -- Access

    start_dates: HASH_TABLE [DATE, STRING]
            -- Start dates - one (or 0) per time-period type

    end_dates: HASH_TABLE [DATE, STRING]
            -- End dates - one (or 0) per time-period type

    last_tradable: TRADABLE [BASIC_TRADABLE_TUPLE]
            -- Last tradable accessed

    caching_on: BOOLEAN
            -- Is market data being cached?

    parameters_for_processor(p: TRADABLE_PROCESSOR; pertype: TIME_PERIOD_TYPE):
        LIST [SESSION_FUNCTION_PARAMETER]
            -- The SESSION_FUNCTION_PARAMETERs associated with the processor `p'
        require
            processor_valid: p /= Void
        local
            parameters: LIST [FUNCTION_PARAMETER]
            pname_occurrences: HASH_TABLE [INTEGER, STRING]
            procname: STRING
        do
            procname := p.name
            if pertype /= Void then
                procname := procname + pertype.name
            end
            Result := params_for_proc[procname]
            if Result = Void then
                parameters := p.parameters
                create pname_occurrences.make(parameters.count)
                create {ARRAYED_LIST [SESSION_FUNCTION_PARAMETER]} Result.make(
                    parameters.count)
                across parameters as pcursor loop
                    Result.extend(create {SESSION_FUNCTION_PARAMETER}.make(
                        pcursor.item, pname_occurrences))
                    if pname_occurrences.has(pcursor.item.verbose_name) then
                        pname_occurrences[pcursor.item.verbose_name] :=
                            pname_occurrences[pcursor.item.verbose_name] + 1
                    else
                        pname_occurrences[pcursor.item.verbose_name] := 1
                    end
                end
                params_for_proc.force(Result, procname)
            end
        ensure
            result_exists: Result /= Void
        end

    cached_event_generators: HASH_TABLE [TRADABLE_EVENT_GENERATOR, STRING]
        -- key: event_type.id.out ":" period_type

    login_date: DATE_TIME

    logoff_date: DATE_TIME

feature -- Element change

    set_last_tradable (arg: TRADABLE [BASIC_TRADABLE_TUPLE])
            -- Set last_tradable to `arg'.
        do
            last_tradable := arg
        ensure
            last_tradable_set: last_tradable = arg
        end

    turn_caching_on
            -- Turn caching on.
        do
            caching_on := True
        ensure
            caching_on: caching_on = True
        end

    turn_caching_off
            -- Turn caching off.
        do
            caching_on := False
        ensure
            caching_off: caching_on = False
        end

feature -- Basic operations

    prepare_processor(p: TRADABLE_PROCESSOR; pertype: TIME_PERIOD_TYPE)
            -- Prepare processor `p' for processing.
        require
            p_exists: p /= Void
        local
            params: LIST [FUNCTION_PARAMETER]
            reference_params: LIST [SESSION_FUNCTION_PARAMETER]
            reference_cursor, param_cursor:
                INDEXABLE_ITERATION_CURSOR [FUNCTION_PARAMETER]
            update_occurred: BOOLEAN
            procname: STRING
        do
            procname := p.name
            if pertype /= Void then
                procname := procname + pertype.name
            end
            reference_params := parameters_for_processor(p, pertype)
            params := p.parameters
            update_occurred := False
            if reference_params.count /= params.count then
                -- Old reference param list no longer valid - discard it:
                params_for_proc.force(Void, procname)
            else
                reference_cursor := reference_params.new_cursor
                param_cursor := params.new_cursor
                from
                    reference_cursor.start
                    param_cursor.start
                invariant
                    reference_cursor.after = param_cursor.after
                until
                    reference_cursor.after
                loop
                    update_occurred := update_parameter(param_cursor.item,
                        reference_cursor.item) or else update_occurred
                    reference_cursor.forth
                    param_cursor.forth
                end
                if update_occurred then
                    p.flag_as_modified
                end
            end
        end

feature {NONE}

    params_for_proc: HASH_TABLE [LIST [SESSION_FUNCTION_PARAMETER], STRING]

    update_parameter(dest_param, src_param: FUNCTION_PARAMETER): BOOLEAN
            -- Ensure dest_param is up to date with src_param; return true if
            -- dest_param was updated.
        require
            same_type: dest_param.value_type_description ~
                src_param.value_type_description
        do
            Result := False
            if
                not dest_param.current_value_equals(
                    src_param.current_value)
            then


                dest_param.change_value(src_param.current_value)
                Result := True
            end
        ensure
            same: dest_param.current_value_equals(src_param.current_value)
        end

invariant

    dates_exist: start_dates /= Void and end_dates /= Void
    params_exist: params_for_proc /= Void
    evgen_cache: cached_event_generators /= Void

end -- class MAS_SESSION
