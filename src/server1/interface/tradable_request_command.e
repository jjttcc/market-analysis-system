note
    description: "A request command that accesses tradables"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class TRADABLE_REQUEST_COMMAND inherit

    MAS_REQUEST_COMMAND
        rename
            make as rcmake
        export
            {NONE} rcmake, initialize
        end

feature {NONE} -- Initialization

    make (dispenser: TRADABLE_DISPENSER)
        require
            not_void: dispenser /= Void
        do
            tradables := dispenser
            rcmake
        ensure
            set: tradables = dispenser and
                tradables /= Void
        end

feature -- Access

    tradables: TRADABLE_DISPENSER
            -- Dispenser of available market lists

feature -- Status setting

    set_tradables (arg: TRADABLE_DISPENSER)
            -- Set tradables to `arg'.
        require
                arg_not_void: arg /= Void
        do
            tradables := arg
        ensure
            tradables_set: tradables = arg and
                tradables /= Void
        end

feature {NONE} -- Hook routines

    ignore_tradable_cache: BOOLEAN
            -- Should `cached_tradable' ignore the "tradable cache"?
        note
            once_status: global
        once
            Result := False
        end

    update_retrieved_tradable: BOOLEAN
            -- Should the tradable retrieved from `tradables' be "updated"
            -- during retrieval?
        note
            once_status: global
        once
            Result := True
        end

feature {NONE} -- Implementation

    report_server_error
        do
            report_error (warning_string, <<"Server error: ",
                tradables.last_error>>)
        end

    server_error: BOOLEAN
            -- Did an error occur in the server?
        do
            Result := tradables.error_occurred
        end

    cached_tradable (symbol: STRING; period_type: TIME_PERIOD_TYPE):
                TRADABLE [BASIC_MARKET_TUPLE]
            -- The tradable corresponding to `symbol' and `period_type' -
            -- `session.last_tradable' is used, if it matches; otherwise
            -- tradables.tradable (symbol, period_type,
            -- update_retrieved_tradable).  Result is Void if either
            -- of `symbol' or `period_type' is not valid.
        require
            not_void: symbol /= Void and period_type /= Void
        do
            Result := session.last_tradable
            if
                ignore_tradable_cache or else Result = Void or
                (not (Result.symbol.is_equal (symbol) and
                Result.period_types.has (period_type.name)))
            then
                Result := Void
                if tradables.valid_period_type (symbol, period_type) then
                    Result := tradables.tradable (symbol, period_type,
                        update_retrieved_tradable)
                end
                session.set_last_tradable (Result)
            end
        ensure
            last_tradable_set: session.last_tradable = Result
            matches_period_type: Result /= Void implies
                Result.period_types.has (period_type.name)
        end

invariant

    tradables_set: tradables /= Void

end -- class TRADABLE_REQUEST_COMMAND
