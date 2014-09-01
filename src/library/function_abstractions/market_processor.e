note
    description:
        "Objects that perform processing on market data using one or %
        %more MARKET_FUNCTIONs and COMMANDs"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class MARKET_PROCESSOR inherit

feature -- Access

    functions: LIST [FUNCTION_PARAMETER]
            -- All functions used directly or indirectly by this market
            -- processor, including itself, if it is a function
        deferred
        ensure
            not_void: Result /= Void
        end

    parameters: LIST [FUNCTION_PARAMETER]
            -- Changeable parameters for `functions'
        deferred
        ensure
            not_void: Result /= Void
        end

    operators: LIST [COMMAND]
            -- All operators used directly or indirectly by this market
            -- processor, including those used by `functions'
        deferred
        ensure
            not_void: Result /= Void
        end

feature -- Status report

    parameter_unames_unique: BOOLEAN
            -- Is each parameter's `unique_name' unique?
        local
            name_used, nused2: HASH_TABLE [INTEGER, STRING]
        do
            create name_used.make(parameters.count)
            Result := parameters.for_all(agent (fp: FUNCTION_PARAMETER;
                nm_u: HASH_TABLE [INTEGER, STRING]): BOOLEAN
                    do
                        Result := True
                        if nm_u.has(fp.unique_name) then
                            Result := False
                            nm_u.put((nm_u @ fp.unique_name) + 1,
                                fp.unique_name)
                        else
                            nm_u.put(1, fp.unique_name)
                        end
                    end
                    (?, name_used))
        end

invariant

    parameters_exist: parameters /= Void

end -- class MARKET_PROCESSOR
