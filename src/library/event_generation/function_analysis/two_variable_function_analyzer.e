indexing
	description:
		"Market analyzer that analyzes two market functions, input1 and %
		%input2, generating an event if input1 crosses (below-to-above, %
		%above-to-below, or both, depending on configuration) input2 with %
		%an optional additional condition provided by an operator"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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
			!!start_date_time.make_now
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
			-- start_date_set_to_now: start_date_time is set to current time
		end

feature -- Access

	input1, input2: MARKET_FUNCTION
			-- The two market functions to be analyzed

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
		end

feature -- Basic operations

	execute is
		do
			!LINKED_LIST [MARKET_EVENT]!product.make
			if not input1.processed then
				input1.process
			end
			if not input2.processed then
				input2.process
			end
			if not target1.empty and not target2.empty then
				do_all
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
						generate_event (target1.item.date_time, "crossover",
							concatenation (<<"Crossover event for ",
							period_type.name,
							" trading period with indicators:%N", input1.name,
							" (", input1.full_description, ") and%N",
							input2.name, " (", input2.full_description, ")%N",
							", values: ",
							target1.item.value, ", ", target2.item.value>>))
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
						generate_event (target1.item.date_time, "crossover",
							concatenation (<<"Crossover event for ",
							period_type.name,
							" trading period with indicators:%N", input1.name,
							" (", input1.full_description, ") and%N",
							input2.name, " (", input2.full_description, ")%N",
							", values: ",
							target1.item.value, ", ", target2.item.value>>))
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

	additional_condition: BOOLEAN is
			-- Is operator Void or is its execution result true?
		do
			if operator /= Void then
				operator.execute (Void)
			end
			Result := operator = Void or else operator.value
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

invariant

	input_not_void: input1 /= Void and input1 /= Void
	date_not_void: start_date_time /= Void
	above_or_below: below_to_above or above_to_below

end -- class TWO_VARIABLE_FUNCTION_ANALYZER
