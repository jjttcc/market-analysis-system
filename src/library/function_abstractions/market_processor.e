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
fparaml: LINEAR [FUNCTION_PARAMETER]
kl: LINEAR [STRING]
i: INTEGER
cursor: hash_table_iteration_cursor [INTEGER, STRING]
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
if not Result then
print("<<<<false result - parame count: " + parameters.count.out + ">>>>%N")
print("current.out, parma.out: " + Current.out + "%N" + parameters.out + "%N")
from
    i := 1
    create nused2.make(parameters.count)
    from
        fparaml := parameters.linear_representation
        fparaml.start
    until
        fparaml.after
    loop
print("params " + i.out + ": " + fparaml.item.unique_name + ": '")
        if nused2.has(fparaml.item.unique_name) then
            nused2[fparaml.item.unique_name] :=
                nused2[fparaml.item.unique_name] + 1
        else
            nused2.put(1, fparaml.item.unique_name)
        end
print(nused2[fparaml.item.unique_name].out + "'%N")
        fparaml.forth
i := i + 1
    end
print("nused2 count: " + nused2.count.out + "%N")
cursor := nused2.new_cursor
cursor.start
until
cursor.after
loop
    print(cursor.key + ": " + cursor.item.out + "%N")
cursor.forth
end
--!!!!!!!Temporary debugging fakeout:
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Result := True
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!handle_assertion_violation
end
        end

invariant

--!!!!???!!![if valid, remove "parameters /= Void implies" from ...unique_names]
    parameters_exist: parameters /= Void

--!!!!!!Possible change of plan - parameter_unique_names may not!!!!!!!!!!!!!
--!!!!!!need to be true!!!!!!!!!!!!
--    parameter_unique_names: parameters /= Void implies parameter_unames_unique

end -- class MARKET_PROCESSOR
