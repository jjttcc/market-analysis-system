indexing
	description:
		"Market analyzer that analyzes two market functions"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TWO_VARIABLE_MARKET_ANALYZER inherit

	MARKET_ANALYZER

	TWO_VARIABLE_LINEAR_ANALYZER
		redefine
			start, action
		end

creation

	make

feature -- Initialization

	make (in1, in2: like input1; op: BOOLEAN_OPERATOR; start_date: DATE_TIME) is
		require
			not_void: in1 /= Void and in2 /= Void and op /= Void and
						start_date /= Void
		do
			set_input1 (in1)
			set_input2 (in2)
			operator := op
			start_date_time := start_date
		ensure
			set: input1 = in1 and input2 = in2 and operator = op and
					start_date_time = start_date
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

feature -- Status setting

	execute is
		do
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
				target1.date_time.is_equal (start_date_time)
			loop
				target1.forth; target2.forth
			end
			check
				dates_equal: target1.date_time.is_equal (start_date_time) and
								target2.date_time.is_equal (start_date_time)
			end
			target1_above := target1.item.value >= target2.item.value
			forth
		ensure then
			target1_above = (target1.item.value >= target2.item.value)
		end

	action is
		local
			crossed_over: BOOLEAN
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
					rabs (target1.item.value - target2.item.value) < epsilon)
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
					rabs (target1.item.value - target2.item.value) < epsilon)
				end
			end
			if crossed_over then
				debug
					print ("crossed over at index1 of "); print (target1.index)
					print (", date: "); print (target1.item.date_time)
					print (", t1, t2 values: ")
					print (target1.item.value); print (target2.item.value)
				end
				if operator /= Void then
					operator.execute
				end
				if operator = Void or else operator.value then
					generate_event
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

end -- class TWO_VARIABLE_MARKET_ANALYZER
