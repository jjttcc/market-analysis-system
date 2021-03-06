note
    description:
        "A complex function whose input consists of tradable data and whose %
        %output is simply its input"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

class TRADABLE_DATA_FUNCTION inherit

    COMPLEX_FUNCTION
        redefine
            set_innermost_input, output, operator_used, process
        end

creation {FACTORY, TRADABLE_FUNCTION_EDITOR}

    make

feature -- Access

    output: like input

    trading_period_type: TIME_PERIOD_TYPE
        do
            Result := input.trading_period_type
        ensure then
            Result = input.trading_period_type
        end

    short_description: STRING
        note
            once_status: global
        once
            Result := "Indicator whose input is basic tradable data and %
                %whose output is simply its input"
        end

    full_description: STRING
        do
            create Result.make (65)
            Result.append (short_description)
            Result.append (":%N")
            Result.append (input.full_description)
        end

    children: LIST [TRADABLE_FUNCTION]
        do
            create {LINKED_LIST [TRADABLE_FUNCTION]} Result.make
            Result.extend (input)
        end

    leaf_functions: LIST [COMPLEX_FUNCTION]
        do
            create {LINKED_LIST [COMPLEX_FUNCTION]} Result.make
            Result.extend (Current)
        end

    innermost_input: SIMPLE_FUNCTION [TRADABLE_TUPLE]
        do
            Result := input
        end

feature -- Status report

    processed: BOOLEAN
        do
            Result := True
        end

    operator_used: BOOLEAN = False

    has_children: BOOLEAN = True

feature -- Basic operations

    process do end

feature {NONE} -- Inapplicable

    do_process do end

    pre_process do end

feature {TRADABLE_FUNCTION_EDITOR}

    set_input, make (in: like input)
        require else
            in_not_void: in /= Void
            in_ptype_not_void: in.trading_period_type /= Void
        do
            input := in
            input.initialize_from_parent(Current)
            output := input
            processed_date_time := input.processed_date_time
        ensure then
            input_set_to_in: input = in
            output_is_input: output = input
            processed_date_time_not_void: processed_date_time /= Void
        end

    set_innermost_input (in: like input)
        require else
            in_not_void: in /= Void
            in_ptype_not_void: in.trading_period_type /= Void
        do
            input := in.twin
            input.initialize_from_parent(Current)
            output := input
            processed_date_time := input.processed_date_time
        ensure then
            input_copied_from_in: input.count = in.count and input.is_equal (in)
            output_is_input: output = input
            processed_date_time_not_void: processed_date_time /= Void
        end

feature {TRADABLE_FUNCTION_EDITOR}

    input: SIMPLE_FUNCTION [BASIC_TRADABLE_TUPLE]

invariant

    always_processed: processed and input.processed
    input_not_void: input /= Void
    output_is_input: output = input
    has_child: has_children and children.count = 1

end -- class TRADABLE_DATA_FUNCTION
