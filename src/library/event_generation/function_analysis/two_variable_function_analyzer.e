indexing
	description:
		"Market analyzer that analyzes two market functions, input1 and %
		%input2, generating an event if input1 crosses (below-to-above, %
		%above-to-below, or both, depending on configuration) input2 with %
		%an optional additional condition provided by an operator"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TWO_VARIABLE_FUNCTION_ANALYZER inherit

	FUNCTION_ANALYZER

	TWO_VARIABLE_LINEAR_ANALYZER
		redefine
			start, action
		end

	MATH_CONSTANTS
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (in1, in2: like input1; ev_type: EVENT_TYPE;
			per_type: TIME_PERIOD_TYPE) is
		require
			not_void: in1 /= Void and in2 /= Void and ev_type /= Void
		do
			set_input1 (in1)
			set_input2 (in2)
			create start_date_time.make_now
			-- EVENT_TYPE instances have a one-to-one correspondence to
			-- FUNTION_ANALYZER instances.  Thus this is the appropriate
			-- place to create this new EVENT_TYPE instance.
			event_type := ev_type
			period_type := per_type
			below_to_above := true
			above_to_below := true
		ensure
			set: input1 = in1 and input2 = in2 and event_type /= Void and
					event_type = ev_type
			period_type_set: period_type = per_type
			both_directions: above_to_below and below_to_above
			use_right: use_right_function
			-- start_date_set_to_now: start_date_time is set to current time
		end

feature -- Access

	input1, input2: MARKET_FUNCTION
			-- The two market functions to be analyzed

	indicators: LIST [MARKET_FUNCTION] is
		do
			create {LINKED_LIST [MARKET_FUNCTION]} Result.make
			Result.extend (input1)
			Result.extend (input2)
		end

	use_left_function: BOOLEAN
			-- Should the operator, if it is not Void, be applied to
			-- the left function?

	use_right_function: BOOLEAN is
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

	set_below_to_above_only is
			-- Set `below_to_above' to true and `above_to_below' to false.
		do
			below_to_above := true
			above_to_below := false
		ensure
			below_to_above_only: below_to_above and not above_to_below
		end

	set_above_to_below_only is
			-- Set `above_to_below' to true and `below_to_above' to false.
		do
			above_to_below := true
			below_to_above := false
		ensure
			above_to_below_only: above_to_below and not below_to_above
		end

	set_below_and_above is
			-- Set both `above_to_below' and `below_to_above' to true.
		do
			above_to_below := true
			below_to_above := true
		ensure
			both: above_to_below and below_to_above
		end

	set_innermost_function (f: SIMPLE_FUNCTION [MARKET_TUPLE]) is
			-- Set the innermost function, which contains the basic
			-- data to be analyzed.
		do
			input1.set_innermost_input (f)
			input2.set_innermost_input (f)
			target1 := input1.output
			target2 := input2.output
			if operator /= Void then
				operator.initialize (Current)
			end
		end

	set_function_for_operation (left: BOOLEAN) is
			-- Specify the function whose output is to be operated on
			-- if `operator' is not void - left (input1) or right (input2).
		do
			use_left_function := left
		ensure
			use_left_function = left and use_right_function /= left
		end

feature -- Basic operations

	execute is
		local
			t: TRADABLE [BASIC_MARKET_TUPLE]
			s: STRING
		do
			check
				tradables_not_void: tradables /= Void
			end
			create {LINKED_LIST [MARKET_EVENT]} product.make
			t := tradables.item (period_type)
			if t /= Void and not tradables.error_occurred then
				set_tradable (t)
				if operator /= Void then set_operator_target end
				if not input1.processed then
					input1.process
				end
				if not input2.processed then
					input2.process
				end
				if not target1.empty and not target2.empty then
					do_all
				end
			else
				if tradables.error_occurred then
					s := concatenation (<<
						"Error occurred during event processing: ",
						tradables.last_error, ".%N">>)
				else
					s := concatenation (<< "Error occurred during event ",
						"processing - failed to process item # ",
						tradables.index, ".%N">>)
				end
				log_error (s)
			end
		end

feature {NONE} -- Hook routine implementation

	start is
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

	action is
		local
			ev_desc: STRING
		do
			-- The crossover_in_effect variable and the check for the
			-- equality (using epsilon) of the 2 values ensures that
			-- multiple crossover events are not generated when the 2
			-- functions remain equal or very close to each other.
			if target1_above then
				if
					target1.item.value <= target2.item.value and
					(not crossover_in_effect or
					rabs (target1.item.value - target2.item.value) >= epsilon)
				then
					if above_to_below and additional_condition then
						generate_event (target1.item, event_description)
					end
					target1_above := false
					crossover_in_effect := true
				else
					crossover_in_effect := crossover_in_effect and
					rabs (target1.item.value - target2.item.value) < epsilon
				end
			else
				if
					target1.item.value >= target2.item.value and
					(not crossover_in_effect or
					rabs (target1.item.value - target2.item.value) >= epsilon)
				then
					if below_to_above and additional_condition then
						generate_event (target1.item, event_description)
					end
					target1_above := true
					crossover_in_effect := true
				else
					crossover_in_effect := crossover_in_effect and
					rabs (target1.item.value - target2.item.value) < epsilon
				end
			end
		end

feature {NONE} -- Implementation

	target1_above: BOOLEAN
			-- Is the current item of target1 above that of target2?

	crossover_in_effect: BOOLEAN
			-- Is the last crossover still in effect?

	operator_target: CHAIN [MARKET_TUPLE]
			-- Target for `operator' to process.

	additional_condition: BOOLEAN is
			-- Is operator Void or is its execution result true?
		do
			if operator /= Void then
				operator.execute (operator_target.item)
			end
			Result := operator = Void or else operator.value
		end

	event_description: STRING is
			-- Constructed description for current event
		do
			Result := concatenation (<<"Crossover for ", period_type.name,
						" trading period with indicators:%N", input1.name,
						" and%N", input2.name, "%Nvalues: ",
						target1.item.value, ", ", target2.item.value>>)
		end

	set_input1 (in: like input1) is
		require
			not_void: in /= Void
			output_not_void: in.output /= Void
		do
			input1 := in
			target1 := in.output
		ensure
			input_set: input1 = in and input1 /= Void
			target_set: target1 = in.output
		end

	set_input2 (in: like input2) is
		require
			not_void: in /= Void
			output_not_void: in.output /= Void
		do
			input2 := in
			target2 := in.output
		ensure
			input_set: input2 = in and input2 /= Void
			target_set: target2 = in.output
		end

	set_operator_target is
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

feature {MARKET_FUNCTION_EDITOR}

	wipe_out is
		local
			dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE]
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
			tradable := Void
		end

feature -- Implementation

	event_name: STRING is "crossover"

invariant

	input_not_void: input1 /= Void and input1 /= Void
	date_not_void: start_date_time /= Void
	above_or_below: below_to_above or above_to_below
	left_xor_right_function: use_left_function xor use_right_function

end -- class TWO_VARIABLE_FUNCTION_ANALYZER
