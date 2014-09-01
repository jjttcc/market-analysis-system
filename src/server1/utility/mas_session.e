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
            create indicator_to_parameters_map.make(0)
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

    last_tradable: TRADABLE [BASIC_MARKET_TUPLE]
            -- Last tradable accessed

    caching_on: BOOLEAN
            -- Is market data being cached?

    parameters_for_indicator(i: MARKET_FUNCTION):
        LIST [SESSION_FUNCTION_PARAMETER]
            -- The SESSION_FUNCTION_PARAMETERs associated with the indicator `i'
        require
            indicator_valid: i /= Void
        local
            parameters: LIST [FUNCTION_PARAMETER]
        do
            Result := indicator_to_parameters_map[i.name]
            if Result = Void then
                parameters := i.parameters
                create {ARRAYED_LIST [SESSION_FUNCTION_PARAMETER]} Result.make(
                    parameters.count)
                across parameters as p loop
                    Result.extend(create {SESSION_FUNCTION_PARAMETER}.make(
                        p.item))
                end
                indicator_to_parameters_map.force(Result, i.name)
            end
        ensure
            result_exists: Result /= Void
        end

    login_date: DATE_TIME

    logoff_date: DATE_TIME

feature -- Element change

    set_last_tradable (arg: TRADABLE [BASIC_MARKET_TUPLE])
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

    prepare_indicator(i: MARKET_FUNCTION)
            -- Prepare indicator `i' for processing.
        local
            params: LIST [FUNCTION_PARAMETER]
            reference_params: LIST [SESSION_FUNCTION_PARAMETER]
            reference_cursor, param_cursor:
                INDEXABLE_ITERATION_CURSOR [FUNCTION_PARAMETER]
            update_occurred: BOOLEAN
        do
            reference_params := parameters_for_indicator(i)
            params := i.parameters
            update_occurred := False
            if reference_params.count /= params.count then
                --!!!!Note: It's unlikely that this condition will ever
                --!!!!occur; but if it does, it might be better to
                --!!!!rebuild 'reference_params' as new list, using 'params',
                --!!!!rather than re-using the existing
                --!!!!('reference_params') list.
                reference_params := synchronized_session_params(i, params,
                    reference_params)
            end
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
                update_occurred := update_parameter(
                        param_cursor.item, reference_cursor.item) or else
                    update_occurred
                reference_cursor.forth
                param_cursor.forth
                check
                    names_match: reference_cursor.item.unique_name ~
                        param_cursor.item.unique_name
                end
            end
            if update_occurred then
                i.flag_as_modified
            end
        end

feature {NONE}

    indicator_to_parameters_map: HASH_TABLE [LIST
        [SESSION_FUNCTION_PARAMETER], STRING]

    synchronized_session_params(i: MARKET_FUNCTION; new_params: LIST
        [FUNCTION_PARAMETER]; ref_params: LIST [SESSION_FUNCTION_PARAMETER]):
                LIST [SESSION_FUNCTION_PARAMETER]
            -- Create a fresh session-function-parameters list, using
            -- ref_params, such that Result mirrors (same order, matching
            -- unique names) new_params - create a new parameter for any
            -- element of new_params not in ref_params; force the new list to
            -- be associated with i.name in indicator_to_parameters_map.
        require
            args: i /= Void and then new_params /= Void and then
                ref_params /= Void
        local
            fp_tbl: HASH_TABLE [SESSION_FUNCTION_PARAMETER, STRING]
            fp: SESSION_FUNCTION_PARAMETER
        do
            create fp_tbl.make(ref_params.count)
            across ref_params as rp loop
                fp_tbl.put(rp.item, rp.item.unique_name)
            end
            create {ARRAYED_LIST [SESSION_FUNCTION_PARAMETER]} Result.make(
                new_params.count)
            across new_params as new_p loop
                fp := fp_tbl[new_p.item.unique_name]
                if fp /= Void then
                    Result.extend(fp)
                else
                    Result.extend(create {SESSION_FUNCTION_PARAMETER}.make(
                        new_p.item))
                end
            end
            indicator_to_parameters_map.force(Result, i.name)
        ensure
            result_mapped: parameters_for_indicator(i) = Result
            synched_count: Result.count = new_params.count
        end

    update_parameter(dest_param, src_param: FUNCTION_PARAMETER): BOOLEAN
            -- Ensure dest_param is up to date with src_param; return true if
            -- dest_param was updated.
        require
            params_match: dest_param.unique_name ~ src_param.unique_name
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
    map_exists: indicator_to_parameters_map /= Void

end -- class MAS_SESSION
