note
    description: "Abstraction for a dispenser of tradables from the list %
        %of all available tradables"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class TRADABLE_DISPENSER

feature -- Access

    item (period_type: TIME_PERIOD_TYPE; update: BOOLEAN):
        TRADABLE [BASIC_TRADABLE_TUPLE]
            -- The tradable at the current cursor position - Void if
            -- `period_type' is not a valid type for the current symbol;
            -- updated with the latest data if `update'.
        require
            type_not_void: period_type /= Void
            cursor_valid: not off
        do
            if valid_period_type (current_symbol, period_type) then
                Result := tradable (current_symbol, period_type, update)
            end
        ensure
            result_definition: Result =
                tradable (current_symbol, period_type, update)
            last_tradable_set: last_tradable = Result
            void_if_not_valid: not valid_period_type (
                current_symbol, period_type) implies Result = Void
        end

    index: INTEGER
            -- Index of current cursor position
        deferred
        end

    tradable (symbol: STRING; period_type: TIME_PERIOD_TYPE; update: BOOLEAN):
                TRADABLE [BASIC_TRADABLE_TUPLE]
            -- The tradable for `period_type' associated with `symbol' -
            -- Void if the tradable for `symbol' is not found or if
            -- `period_type' is not a valid type for `symbol'; updated with
            -- the latest data if `update'
        require
            not_empty: not is_empty
            not_void: symbol /= Void and period_type /= Void
        deferred
        ensure
            period_type_valid: Result /= Void implies
                Result.valid_period_type (period_type)
            last_tradable_set: last_tradable = Result
            not_void_if_valid_and_no_error: not error_occurred and
                valid_period_type (symbol, period_type) implies Result /= Void
            intraday_correspondence: Result /= Void implies
                period_type.intraday = Result.trading_period_type.intraday
            void_if_not_valid: not valid_period_type (symbol, period_type)
                implies Result = Void
        end

    tuple_list (symbol: STRING; period_type: TIME_PERIOD_TYPE; update: BOOLEAN):
                SIMPLE_FUNCTION [BASIC_TRADABLE_TUPLE]
            -- Tuple list for `period_type' for tradable with `symbol' - Void
            -- if the tradable for `symbol' is not found or if `period_type'
            -- is not a valid type for `symbol'; updated with
            -- the latest data if `update'.  `last_tradable' will be set
            -- to `tradable (symbol, period_type)'.
        require
            not_empty: not is_empty
            not_void: symbol /= Void and period_type /= Void
            period_type_valid: valid_period_type (symbol, period_type)
        local
            t: TRADABLE [BASIC_TRADABLE_TUPLE]
        do
            t := tradable (symbol, period_type, update)
            if t /= Void then
                Result := t.tuple_list (period_type.name)
            end
        ensure
            same_period_type: Result /= Void implies
                Result.trading_period_type.is_equal (period_type)
            not_void_if_no_error: not error_occurred implies Result /= Void
        end

    symbols: DYNAMIC_LIST [STRING]
            -- The symbol of each tradable
        deferred
        ensure
            object_comparison: Result.object_comparison
            not_void_if_no_error: not error_occurred implies Result /= Void
        end

    period_type_names_for (symbol: STRING): ARRAYED_LIST [STRING]
            -- Names of all period types available for `symbol', sorted in
            -- ascending order according to period-type duration -
            -- Void if the tradable for `symbol' is not found
        require
            not_empty: not is_empty
            not_void: symbol /= Void
            symbol_valid: symbols.has (symbol)
        deferred
        ensure
            not_void_if_no_error: not error_occurred implies Result /= Void
        end

    period_types_for (symbol: STRING): LIST [TIME_PERIOD_TYPE]
            -- All period types available for `symbol', sorted in
            -- ascending order according to period-type duration -
            -- Void if the tradable for `symbol' is not found
        require
            not_empty: not is_empty
            not_void: symbol /= Void
            symbol_valid: symbols.has (symbol)
        local
            names: LIST [STRING]
            gs: expanded GLOBAL_SERVICES
        do
            create {LINKED_LIST [TIME_PERIOD_TYPE]} Result.make
            names := period_type_names_for (symbol)
            if names /= Void then
                from
                    names.start
                until
                    names.exhausted
                loop
                    Result.extend (gs.period_types @ names.item)
                    names.forth
                end
            end
        ensure
            not_void_if_no_error: not error_occurred implies Result /= Void
            all_valid: Result.for_all (agent valid_period_type (symbol, ?))
        end

    indicators: SEQUENCE [TRADABLE_FUNCTION]
            -- All indicators currently known to the system
        deferred
        end

    current_symbol: STRING
            -- Symbol at the current cursor position
        require
            cursor_valid: not off
        deferred
        ensure
            result_valid: Result /= Void
        end

    last_tradable: TRADABLE [BASIC_TRADABLE_TUPLE]
            -- Last tradable accessed

    indicator_with_name(n: STRING): TRADABLE_FUNCTION
            -- Element of `indicators' with name `n'
        deferred
        end

    last_error: STRING
            -- Description of last error

feature -- Status report

    expandable: BOOLEAN
            -- Can new "tradable"s be added to the list of available tradables?
        deferred
        end

    error_occurred: BOOLEAN
            -- Did an error occur during the last operation?

    after: BOOLEAN
            -- Is there no valid position to the right of the current
            -- cursor position?
        deferred
        end

    is_empty: BOOLEAN
            -- Are there no tradables?
        deferred
        end

    isfirst: BOOLEAN
            -- Is the cursor at the first position?
        deferred
        end

    exhausted: BOOLEAN
            -- Has the dispenser been completely explored?
        do
            Result := off
        ensure
            exhausted_when_off: off implies Result
        end

    off: BOOLEAN
            -- Is there no current item?
        deferred
        end

    caching_on: BOOLEAN
            -- Is cahing of tradable data turned on?
        deferred
        end

    valid_period_type (symbol: STRING; t: TIME_PERIOD_TYPE): BOOLEAN
            -- Is `t' a valid period type for the tradable with symbol
            -- `symbol'?
        require
            not_void: symbol /= Void and t /= Void
            not_empty: not is_empty
        local
            restore_reference_comparison: BOOLEAN
            ptypes: LIST [STRING]
            error: BOOLEAN
        do
            error := error_occurred
            error_occurred := False
            if symbols.has (symbol) then
                ptypes := period_type_names_for (symbol)
                if ptypes /= Void then
                    if not ptypes.object_comparison then
                        restore_reference_comparison := True
                        ptypes.compare_objects
                    end
                    Result := ptypes.has (t.name)
                    if restore_reference_comparison then
                        ptypes.compare_references
                    end
                end
            end
            -- `error_occurred' may have been reset to False by one of the
            -- routines called above; being a simple query, this routine
            -- needs to restore it to its original value, unless it was
            -- set to True within this routine (by a called routine).
            if not error_occurred then
                error_occurred := error
            end
        end

feature -- Cursor movement

    forth
            -- Move to next position; if no next position, ensure
            -- `exhausted'.
        require
            not_after: not after
        deferred
        ensure
            index_incremented: index = old index + 1
        end

    start
        deferred
        ensure
            not is_empty = not after
            atfirst: not is_empty implies isfirst
        end

feature -- Basic operations

    clear_caches
            -- Clear all caches - that is, force re-reading of tradable data.
        deferred
        end

    turn_caching_off
            -- Turn off caching of tradable data.
        deferred
        ensure
            caching_off: not caching_on
        end

    turn_caching_on
            -- Turn on caching of tradable data.
        deferred
        ensure
            caching_on: caching_on
        end

    attempt_to_add (symbol: STRING; t: TIME_PERIOD_TYPE)
            -- Attempt to add a new tradable for `symbol' to the list of
            -- tradables.  Raise an exception if the attempt fails.
        require
            args_exist: symbol /= Void and t /= Void
            expandable: expandable
            symbol_not_known: not symbols.has(symbol)
        deferred
        end

invariant

    after_constraint: after implies off
    empty_constraint: is_empty implies off
    indicators_exist: not error_occurred implies indicators /= Void

end -- class TRADABLE_DISPENSER
