indexing
	description: 
		"A market function that takes two arguments or variables"
	date: "$Date$";
	revision: "$Revision$"

class TWO_VARIABLE_FUNCTION

inherit

	MARKET_FUNCTION
		redefine
			pre_process
		end

	LINEAR_ANALYZER
		rename
			target as target1, -- x in "z = f(x, y)"
			set_target as set_target_unused
		export {NONE}
			set_target_unused
		redefine
			forth, action, start
		select
			target1, forth, action, start
		end

	LINEAR_ANALYZER
		rename
			target as target2, -- y in "z = f(x, y)"
			forth as forth_unused,
			action as action_unused,
			start as start_unused,
			set_target as set_target_unused
		export {NONE}
			set_target_unused
		end

creation {FACTORY}

	make

feature {NONE} -- Initialization

	make (in1: like input1; in2: like input2; op: NUMERIC_COMMAND)  is
		require
			args_not_void: in1 /= Void and in2 /= Void
			op_not_void_if_used: operator_used implies op /= Void
			in_output_not_void: in1.output /= Void and in2.output /= Void
		do
			!!output.make (in1.output.count)
			set_input (in1, in2)
			set_operator (op)
		ensure
			output_not_void: output /= Void
			set: input1 = in1 and input2 = in2 and operator = op
		end

feature -- Access

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]

feature -- Status report

	processed: BOOLEAN is
		do
			Result := (input1.processed and input2.processed) and then
				target1.empty or target2.empty or not output.empty
		ensure then
			Result = ((input1.processed and input2.processed) and then
				target1.empty or target2.empty or not output.empty)
		end

	arg_used: BOOLEAN is false

	operator_used: BOOLEAN is true

feature {NONE}

	forth is
		do
			target1.forth
			target2.forth
		ensure then
			target_indexes_incremented_by_one:
				target1.index = old target1.index + 1
				target2.index = old target2.index + 1
		end

	start is
		do
			line_up (target1, target2)
		ensure then
			current_targets_dates_equal:
				target1.item.date_time.is_equal (target2.item.date_time)
		end

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (Void)
			!!t
			t.set_value (operator.value)
			check
				target1.item.date_time.is_equal (
					target2.item.date_time)
			end
			t.set_date_time (target1.item.date_time)
			output.extend (t)
		ensure then
			output.count = old (output.count) + 1
		end

	do_process is
		do
			do_all
		end

	pre_process is
		do
			if not input1.processed then
				input1.process (Void)
			end
			if not input2.processed then
				input2.process (Void)
			end
		ensure then
			input1_1_processed: input1.processed and input2.processed
		end

feature {NONE}

	missing_periods (l1, l2: LINEAR [MARKET_TUPLE]): BOOLEAN is
			-- Are there missing periods in l1 and l2 with
			-- respect to each other?
			--!!!Move this to a utility class?
		require
			both_void_or_both_not: (l1 = Void) = (l2 = Void)
		do
			if l1 /= Void then
				check l2 /= Void end
				from
					line_up (l1, l2)
				until
					Result or l1.after or l2.after
				loop
					if
						not l1.item.date_time.is_equal (
												l2.item.date_time)
					then
						Result := true
					end
					l1.forth; l2.forth
				end
				if not Result and l1.after /= l2.after then
					Result := true
				end
			else
				check l1 = Void and l2 = Void and not Result end
			end
		ensure
			void_gives_false: (l1 = Void and l2 = Void) implies (Result = false)
		end

	line_up (t1, t2: LINEAR [MARKET_TUPLE]) is
			-- Line up t1 and t2 so that they start on the same time period.
			--!!!Move this to a utility class?
		local
			l1, l2: LINEAR [MARKET_TUPLE]
		do
			--!!!What if t1 or t2 is empty?
			t1.start; t2.start
			from
				if t1.item.date_time < t2.item.date_time then
					l1 := t1
					l2 := t2
				else
					l1 := t2
					l2 := t1
				end
			until
				not (l1.item.date_time < l2.item.date_time)
			loop
				l1.forth
			end
		end

feature {TEST_FUNCTION_FACTORY} -- Element change (Export to test class for now.)

	set_input (f1: like input1; f2: like input2) is
		require
			not_void: f1 /= Void and f2 /= Void
			outputs_not_void: f1.output /= Void and f2.output /= Void
			output_not_void: output /= Void
		do
			input1 := f1
			input2 := f2
			target1 := f1.output
			target2 := f2.output
			check output /= Void end
			output.wipe_out
		ensure
			functions_set: input1 = f1 and input2 = f2 and
							input1 /= Void and input2 /= Void
			output_empty: output.empty
		end

feature {NONE}

	input1, input2: MARKET_FUNCTION

invariant

	processed_constraint:
		 processed implies input1.processed and input2.processed
	inputs_not_void: input1 /= Void and input2 /= Void
	target2_not_void: target2 /= Void
	input_target_relation:
		input1.output = target1 and input2.output = target2
	no_missing_periods: not missing_periods (target1, target2)

end -- class TWO_VARIABLE_FUNCTION
