note
    description:
        "Analyzer that analyzes two tradable functions, input1 and %
        %input2, generating an event if input1 crosses (below-to-above, %
        %above-to-below, or both, depending on configuration) input2 with %
        %an optional additional condition provided by an operator"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

class TWO_VARIABLE_FUNCTION_ANALYZER inherit

    FUNCTION_ANALYZER
        redefine
            initialize_from_parent 
        end

    TWO_VARIABLE_LINEAR_ANALYZER
        redefine
            start, action, exhausted
        end

    MATH_CONSTANTS
        export {NONE}
            all
        end

creation

    make

feature -- Initialization

    make (in1, in2: like input1; ev_type: EVENT_TYPE; sig_type: INTEGER;
            per_type: TIME_PERIOD_TYPE)
        require
            not_void: in1 /= Void and in2 /= Void and ev_type /= Void
        do
            set_input1 (in1)
            set_input2 (in2)
            create start_date_time.make_now
            create end_date_time.make_now
            -- EVENT_TYPE instances have a one-to-one correspondence to
            -- FUNTION_ANALYZER instances.  Thus this is the appropriate
            -- place to create this new EVENT_TYPE instance.
            event_type := ev_type
            period_type := per_type
            signal_type := sig_type
            below_to_above := True
            above_to_below := True
        ensure
            set: input1 = in1 and input2 = in2 and event_type /= Void and
                event_type = ev_type and signal_type = sig_type
            period_type_set: period_type = per_type
            both_directions: above_to_below and below_to_above
            use_right: use_right_function
            -- start_date_set_to_now: start_date_time is set to current time
            -- end_date_set_to_now: end_date_time is set to current time
        end

feature -- Access

    input1, input2: TRADABLE_FUNCTION
            -- The two tradable functions to be analyzed

    indicators: LIST [TRADABLE_FUNCTION]
        do
            create {LINKED_LIST [TRADABLE_FUNCTION]} Result.make
            Result.extend (input1)
            Result.extend (input2)
        end

    use_left_function: BOOLEAN
            -- Should the operator, if it is not Void, be applied to
            -- the left function?

    use_right_function: BOOLEAN
            -- Should the operator, if it is not Void, be applied to
            -- the right function?
        do
            Result := not use_left_function
        end

feature -- Status report

    below_to_above: BOOLEAN
            -- Will events be generated if the output from `input1'
            -- crosses from below input2 to above it?

    above_to_below: BOOLEAN
            -- Will events be generated if the output from `input1'
            -- crosses from above input2 to below it?

feature -- Status setting

    set_below_to_above_only
            -- Set `below_to_above' to True and `above_to_below' to False.
        do
            below_to_above := True
            above_to_below := False
        ensure
            below_to_above_only: below_to_above and not above_to_below
        end

    set_above_to_below_only
            -- Set `above_to_below' to True and `below_to_above' to False.
        do
            above_to_below := True
            below_to_above := False
        ensure
            above_to_below_only: above_to_below and not below_to_above
        end

    set_below_and_above
            -- Set both `above_to_below' and `below_to_above' to True.
        do
            above_to_below := True
            below_to_above := True
        ensure
            both: above_to_below and below_to_above
        end

    set_innermost_function (f: SIMPLE_FUNCTION [TRADABLE_TUPLE])
            -- Set the innermost function, which contains the basic
            -- data to be analyzed.
        do
            input1.set_innermost_input (f)
            input2.set_innermost_input (f)
            set1 (input1.output)
            set2 (input2.output)
            if operator /= Void then
                operator.initialize (Current)
            end
        end

    set_function_for_operation (left: BOOLEAN)
            -- Specify the function whose output is to be operated on
            -- if `operator' is not void - left (input1) or right (input2).
        do
            use_left_function := left
        ensure
            use_left_function = left and use_right_function /= left
        end

    initialize_from_parent(p: TREE_NODE)
        do
            if parents_implementation = Void then
                create {LINKED_LIST [TREE_NODE]} parents_implementation.make
            end
            -- Prevent adding the same parent twice.
            if not is_parent(p) then
                parents_implementation.extend(p)
            end
        ensure then
            p_is_a_parent: parents.has(p)
        end

feature -- Basic operations

    execute
        do
            create {LINKED_LIST [TRADABLE_EVENT]} product.make
            if current_tradable /= Void then
                if operator /= Void then set_operator_target end
                if not input1.processed then
                    input1.process
                end
                if not input2.processed then
                    input2.process
                end
                if not target1.is_empty and not target2.is_empty then
                    do_all
                end
            end
        end

    debugging_report
        local
            parms: LIST [FUNCTION_PARAMETER]
            fp: FUNCTION_PARAMETER
        do
            print("analyzer: " + Current.out + "%N")
            print("product.count: " + product.count.out + "%N")
            print("period_type: " + period_type.name + "%N")
            print("parameters:%N")
            parms := parameters
            from parms.start until parms.exhausted loop
                fp := parms.item
                print("value: " + fp.current_value + ", name: " +
                    fp.verbose_name + "%N")
                parms.forth
            end
        end

feature {NONE} -- Hook routine implementation

    exhausted: BOOLEAN
        do
			Result := Precursor or else target1.item.date_time > end_date_time
        end

    start
        do
            from
                Precursor
            until
                target1.exhausted or target2.exhausted or
                target1.item.date_time >= start_date_time
            loop
                target1.forth; target2.forth
            end
            if not target1.exhausted and not target2.exhausted then
                check
                    dates_not_earlier:
                        target1.item.date_time >= start_date_time
                        and target2.item.date_time >= start_date_time
                end
                target1_above := target1.item.value >= target2.item.value
                forth
            end
        ensure then
            above_set: not target1.exhausted and not target2.exhausted implies
                target1_above = (target1.i_th (target1.index - 1).value >=
                                target2.i_th (target2.index - 1).value)
        end

    action
        do
            -- The crossover_in_effect variable and the check for the
            -- equality (using epsilon) of the 2 values ensures that
            -- multiple crossover events are not generated when the 2
            -- functions remain equal or very close to each other.
            if target1_above then
                if
                    target1.item.value <= target2.item.value and
                    (not crossover_in_effect or
                    dabs (target1.item.value - target2.item.value) >= epsilon)
                then
                    if above_to_below and additional_condition then
                        generate_event (target1.item, event_description)
                    end
                    target1_above := False
                    crossover_in_effect := True
                else
                    crossover_in_effect := crossover_in_effect and
                    dabs (target1.item.value - target2.item.value) < epsilon
                end
            else
                if
                    target1.item.value >= target2.item.value and
                    (not crossover_in_effect or
                    dabs (target1.item.value - target2.item.value) >= epsilon)
                then
                    if below_to_above and additional_condition then
                        generate_event (target1.item, event_description)
                    end
                    target1_above := True
                    crossover_in_effect := True
                else
                    crossover_in_effect := crossover_in_effect and
                    dabs (target1.item.value - target2.item.value) < epsilon
                end
            end
        end

feature {NONE} -- Implementation

    target1_above: BOOLEAN
            -- Is the current item of target1 above that of target2?

    crossover_in_effect: BOOLEAN
            -- Is the last crossover still in effect?

    operator_target: CHAIN [TRADABLE_TUPLE]
            -- Target for `operator' to process.

    additional_condition: BOOLEAN
            -- Is operator Void or is its execution result True?
        do
            if operator /= Void then
                operator.execute (operator_target.item)
            end
            Result := operator = Void or else operator.value
        end

    event_description: STRING
            -- Constructed description for current event
        do
            Result := concatenation (<<"Crossover for ", period_type.name,
                        " trading period with indicators:%N", input1.name,
                        " and%N", input2.name, "%Nvalues: ",
                        target1.item.value, ", ", target2.item.value>>)
        end

    set_input1 (in: like input1)
        require
            not_void: in /= Void
            output_not_void: in.output /= Void
        do
            input1 := in
            set1(in.output)
            input1.initialize_from_parent(Current)
        ensure
            input_set: input1 = in and input1 /= Void
            target_set: target1 = in.output
        end

    set_input2 (in: like input2)
        require
            not_void: in /= Void
            output_not_void: in.output /= Void
        do
            input2 := in
            set2 (in.output)
            input2.initialize_from_parent(Current)
        ensure
            input_set: input2 = in and input2 /= Void
            target_set: target2 = in.output
        end

    set_operator_target
            -- Set `operator_target' according to `use_left_function' and
            -- `use_right_function'.  Must be called after set_tradable.
        do
            if use_left_function then
                operator_target := target1
            else
                operator_target := target2
            end
        ensure
            left_tgt1: use_left_function implies operator_target = target1
            right_tgt2: not use_left_function implies operator_target = target2
        end

feature {TRADABLE_FUNCTION_EDITOR}

    wipe_out
        local
            dummy_tradable: TRADABLE [BASIC_TRADABLE_TUPLE]
        do
            create {STOCK} dummy_tradable.make ("dummy", Void, Void)
            dummy_tradable.set_trading_period_type (
                period_types @ (period_type_names @ Daily))
            -- Set innermost input to an empty tradable to force it
            -- to clear its contents.
            input1.set_innermost_input (dummy_tradable)
            input2.set_innermost_input (dummy_tradable)
            target1 := input1.output
            target2 := input2.output
            product := Void
            current_tradable := Void
        end

feature -- Implementation

    event_name: STRING = "crossover"

invariant

    input_not_void: input1 /= Void and input1 /= Void
    dates_not_void: start_date_time /= Void and end_date_time /= Void
    above_or_below: below_to_above or above_to_below
    left_xor_right_function: use_left_function xor use_right_function

end -- class TWO_VARIABLE_FUNCTION_ANALYZER
