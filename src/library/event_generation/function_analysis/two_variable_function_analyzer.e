indexing
	description:
		"Market analyzer that analyzes two market functions"
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

creation

	make

feature -- Initialization

	make (in1, in2: like input1; event_type_name: STRING;
			per_type: TIME_PERIOD_TYPE) is
		require
			not_void: in1 /= Void and in2 /= Void and event_type_name /= Void
		do
			set_input1 (in1)
			set_input2 (in2)
			!!start_date_time.make_now
			debug -- Temporary - for testing
				!!start_date_time.make (1997, 10, 1, 0, 0, 0)
			end
			-- EVENT_TYPE instances have a one-to-one correspondence to
			-- FUNTION_ANALYZER instances.  Thus this is the appropriate
			-- place to create this new EVENT_TYPE instance.
			set_event_type (event_type_name)
			period_type := per_type
		ensure
			set: input1 = in1 and input2 = in2 and event_type /= Void and
					event_type.name.is_equal (event_type_name)
			period_type_set: period_type = per_type
			start_date_set_to_now: -- start_date_time is set to current time
		end

feature -- Access

	input1, input2: MARKET_FUNCTION
			-- The two market functions to be analyzed

feature -- Status setting

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
			!LINKED_LIST [EVENT]!product.make
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
			crossed_over: BOOLEAN
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
					crossed_over := true
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
					crossed_over := true
					target1_above := true
					crossover_in_effect := true
				else
					crossover_in_effect := crossover_in_effect and
					rabs (target1.item.value - target2.item.value) < epsilon
				end
			end
			if crossed_over then
				if operator /= Void then
					operator.execute (Void)
				end
				if operator = Void or else operator.value then
					ev_desc := concatenation (<<"Crossover event for ",
						period_type.name, " trading period with indicators ",
						input1.name, " and ", input2.name, ", values: ",
						target1.item.value, ", ", target2.item.value>>)
					generate_event (target1.item.date_time, "crossover",
										ev_desc)
				end
			end
		end

feature {NONE} -- Implementation

	target1_above: BOOLEAN
			-- Is the current item of target1 above that of target2?

	crossover_in_effect: BOOLEAN
			-- Is the last crossover still in effect?

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
	event_type_not_void: event_type /= Void
	date_not_void: start_date_time /= Void

end -- class TWO_VARIABLE_FUNCTION_ANALYZER
