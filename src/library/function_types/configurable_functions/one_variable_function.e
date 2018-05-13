note
    description:
        "A tradable function that takes one argument or variable"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

class ONE_VARIABLE_FUNCTION inherit

    COMPLEX_FUNCTION
        redefine
            set_innermost_input, reset_parameters, flag_as_modified,
            append_to_name, who_am_i__parent, processor_type
        end

    SETTABLE_LINEAR_ANALYZER
        export {NONE}
            set
        redefine
            action, start
        end

creation {FACTORY, TRADABLE_FUNCTION_EDITOR}

    make

feature {NONE} -- Initialization

    make (in: like input; op: like operator)
        require
            in_not_void: in /= Void
            op_not_void_if_used: operator_used implies op /= Void
            in_output_not_void: in.output /= Void
            in_ptype_not_void: in.trading_period_type /= Void
        do
            set_input (in)
            make_output
            if op /= Void then
                set_operator (op)
                operator.initialize (Current)
            end
        ensure
            set: input = in and operator = op
            target_not_void: target /= Void
        end

feature -- Access

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
            Result := "Indicator that operates on a data sequence"
        end

    full_description: STRING
        do
            create Result.make (25)
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
        local
            f: COMPLEX_FUNCTION
        do
            create {LINKED_LIST [COMPLEX_FUNCTION]} Result.make
            if input.is_complex then
                f ?= input
                Result.append (f.leaf_functions)
            else
                Result.extend (Current)
            end
        end

    innermost_input: SIMPLE_FUNCTION [TRADABLE_TUPLE]
        do
            if input.is_complex then
                Result := input.innermost_input
            else
                Result ?= input
            end
        ensure then
            exists: Result /= Void
        end

    processor_type: STRING = "one-var func"

feature {FACTORY, TRADABLE_FUNCTION_EDITOR} -- Element change

    append_to_name (suffix, separator: STRING)
        do
io.error.print("append_to_name called with '" + suffix + "'" +
" [" + generating_type+ "]%N")
            name_suffix := separator.twin + suffix.twin
--!!!!!!!??????Should this happen?:!!!!
            input.append_to_name(suffix, separator)
        end

feature {FACTORY} -- Element change

    set_innermost_input (in: SIMPLE_FUNCTION [BASIC_TRADABLE_TUPLE])
        do
            processed_date_time := Void
            if input.is_complex then
                input.set_innermost_input (in)
--!!!!in.initialize_from_parent(Current)?? - guess: NO!!!!!
            else
                set_input (in)
                -- Allow all linear commands in the operator hierarchy to
                -- update their targets with the new `input' object.
                -- It's only when 'not input.is_complex' that this needs to
                -- be done (that is, Current is a complex leaf function) -
                -- the linear operators of non-leaf functions need to keep
                -- their existing targets, which are the `output's of
                -- complex functions, to maintain the functions semantics.
                initialize_operators
            end
            output.wipe_out
        end

feature -- Status setting

    flag_as_modified
        do
            processed_date_time := Void
--!!!!!CHECK CORRECTNESS:
            input.flag_as_modified
--!!!!![END CHECK]
        ensure then
            modified: not processed
        end

feature -- Status report

    processed: BOOLEAN
        do
            Result := input.processed and then
                        processed_date_time /= Void and then
                        processed_date_time >= input.processed_date_time
        end

    has_children: BOOLEAN = True

feature {NONE}

    action
        do
            operator.execute (target.item)
            add_operator_result
            if debugging then
                print_status_report
            end
        ensure then
            one_more_in_output: output.count = old output.count + 1
            date_time_correspondence:
                output.last.date_time.is_equal (target.item.date_time)
        end

    start
        do
            Precursor
        end

    do_process
            -- Execute the function.
        do
            do_all
        end

    pre_process
        do
            if not output.is_empty then
                output.wipe_out
            end
            if not input.processed then
                input.process
            end
        ensure then
            input_processed: input.processed
        end

feature {TRADABLE_FUNCTION_EDITOR}

    set_input (in: like input)
        require
            in_not_void: in /= Void and in.output /= Void
            ptype_not_void: in.trading_period_type /= Void
        do
            input := in
            input.initialize_from_parent(Current)
            set(input.output)
            processed_date_time := Void
        ensure
            input_set_to_in: input = in
            not_processed: not processed
            parents_set: input.parents.has(Current)
        end

    reset_parameters
        do
            input.reset_parameters
        end

feature {TRADABLE_FUNCTION_EDITOR}

    input: TRADABLE_FUNCTION

feature {TREE_NODE} -- Implementation

    who_am_i__parent (child: TREE_NODE): STRING
        do
            Result := ""
            if child = input then
                Result := who_am_i_intro + "input function"
            elseif child = operator then
                Result := who_am_i_intro + "operator"
            end
            if not Result.empty then
                Result := Result + recursive_who_am_i
            else
                -- Since Result is empty, assume Current is not its parent
                -- and leave it empty.
            end
        end

feature {NONE} -- Implementation

    make_output
        do
            create output.make (target.count)
        end

    initialize_operators
            -- Initialize all operators that are not Void - default:
            -- initialize `operator' if it's not Void.
        do
            if operator /= Void then
                -- operator will set its target to new input.output.
                operator.initialize (Current)
            end
        end

    add_operator_result
        local
            t: SIMPLE_TUPLE
        do
            create t.make (target.item.date_time,
                target.item.end_date, operator.value)
            output.extend (t)
        end

invariant

    processed_constraint: processed implies input.processed
    input_not_void: input /= Void
    input_target_relation: input.output = target
    has_one_child: has_children and children.count = 1

end -- class ONE_VARIABLE_FUNCTION
