note
    description:
        "A changeable parameter for a tradable function, such as n for an %
        %n-period moving average."
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class FUNCTION_PARAMETER inherit

    PART_COMPARABLE
        redefine
            is_equal
        end

feature {NONE} -- Initialization

feature -- Access

    current_value: STRING
            -- Current value of the parameter
        deferred
        end

    name: STRING assign set_name
            -- The name of the parameter
        deferred
        end

    description: STRING
        deferred
        end

    verbose_name: STRING
            -- "verbose" (hopefully unique [i.e., unique among parameters
            -- belonging to a particular TRADABLE_FUNCTION] but not
            -- guaranteed) name for the parameter
        do
            Result := description
        end

    value_type_description: STRING
            -- Description of the type needed by `current_value'.
        deferred
        end

    current_value_equals (v: STRING): BOOLEAN
            -- Does `v' match the current value according to the
            -- internal type of the value?
        deferred
        end

    owner: TREE_NODE
            -- Owner associated with this FUNCTION_PARAMETER
        deferred
        end

feature -- Comparison

    infix "<" (other: FUNCTION_PARAMETER): BOOLEAN
        do
            Result := description < other.description
        end

    is_equal (other: like Current): BOOLEAN
        do
            -- Redefined here to allow descendants to compare with other
            -- FUNCTION_PARAMETERs instead of "like Current".
            Result := Precursor (other)
        end

feature -- Element change

    change_value (new_value: STRING)
            -- Change the value of the parameter to `new_value'.
        require
            value_valid: valid_value (new_value)
        deferred
        ensure
            current_value_equals (new_value)
        end

    set_name (n: STRING)
        require
            existence: n /= Void
        do
        end

feature -- Basic operations

    valid_value (i: STRING): BOOLEAN
            -- Is `i' a valid value for this parameter?
        deferred
        end

end -- class FUNCTION_PARAMETER
