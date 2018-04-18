note
    description:
        "Objects that perform processing on tradable (e.g., stock or %
        %commodity) data using one or more FUNCTION_PARAMETERs and COMMANDs"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class TRADABLE_PROCESSOR inherit

    TREE_NODE

feature -- Access

    functions: LIST [FUNCTION_PARAMETER]
            -- All functions used directly or indirectly by this tradable
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
            -- All operators used directly or indirectly by this tradable
            -- processor, including those used by `functions'
        deferred
        ensure
            not_void: Result /= Void
        end

    position_of_parameter (p: FUNCTION_PARAMETER): INTEGER
            -- Position of `p' in `parameters'
        local
            params: LIST [FUNCTION_PARAMETER]
        do
            params := parameters
            params.compare_objects
            Result := params.index_of(p, 1)
        end

feature -- Status report

    parameter_unames_unique: BOOLEAN
            -- Is each parameter's `unique_name' unique?
        local
            name_used: HASH_TABLE [INTEGER, STRING]
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

feature -- Status setting

    flag_as_modified
			-- If this function is modifiable, flag it as having been modified;
			-- otherwise, do nothing.
        do
			-- [Redefine if needed]
        end

invariant

    parameters_exist: parameters /= Void

end -- class TRADABLE_PROCESSOR
