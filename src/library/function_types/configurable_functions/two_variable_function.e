indexing
	description: 
		"A market function that takes two arguments or variables"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TWO_VARIABLE_FUNCTION

inherit

	MARKET_FUNCTION
		redefine
			pre_process, update_processed_date_time
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
			target1
		end

	LINEAR_ANALYZER
		rename
			target as target2, -- y in "z = f(x, y)"
			set_target as set_target_unused
		export {NONE}
			set_target_unused
		redefine
			forth, action, start
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

	trading_period_type: TIME_PERIOD_TYPE is
		do
			Result := input1.trading_period_type
		ensure then
			Result = input1.trading_period_type
		end

	short_description: STRING is
		once
			Result := "Indicator that operates on two data sequences"
		end

	full_description: STRING is
		do
			!!Result.make (25)
			Result.append (short_description)
			Result.append (":%N")
			Result.append (input1.full_description)
			Result.append ("; and:%N")
			Result.append (input2.full_description)
		end

	parameters: LIST [FUNCTION_PARAMETER] is
		local
			parameter_set: LINKED_SET [FUNCTION_PARAMETER]
		do
			if parameter_list = Void then
				!!parameter_list.make
				!!parameter_set.make
				if immediate_parameters /= Void then
					parameter_set.fill (immediate_parameters)
				end
				check
					input_parameters_not_void:
						input1.parameters /= Void and
						input2.parameters /= Void
				end
				parameter_set.fill (input1.parameters)
				parameter_set.fill (input2.parameters)
				parameter_list.append (parameter_set)
			end
			Result := parameter_list
		end

	processed_date_time: DATE_TIME

feature -- Status report

	processed: BOOLEAN is
		do
			Result := (input1.processed and input2.processed) and then
					processed_date_time /= Void and then
					processed_date_time >= input1.processed_date_time and then
					processed_date_time >= input2.processed_date_time
		end

	operator_used: BOOLEAN is true

feature {NONE} -- Hook methods

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
			if target1.empty or target2.empty then
				-- null statement
			else
				do_all
			end
		ensure then
			output_empty_when_target_empty:
				target1.empty or target2.empty implies output.empty
		end

	pre_process is
		do
			if not output.empty then
				output.wipe_out
			end
			if not input1.processed then
				input1.process
			end
			if not input2.processed then
				input2.process
			end
		ensure then
			inputs_processed: input1.processed and input2.processed
		end

	update_processed_date_time is
		do
			if processed_date_time = Void then
				!!processed_date_time.make_now
			else
				processed_date_time.make_now
			end
		end

feature {NONE}

	missing_periods (l1, l2: LINEAR [MARKET_TUPLE]): BOOLEAN is
			-- Are there missing periods in l1 and l2 with
			-- respect to each other?
		require
			both_void_or_both_not: (l1 = Void) = (l2 = Void)
		do
			if l1 /= Void and then not l1.empty and not l2.empty then
				check l2 /= Void end
				from
					line_up (l1, l2)
				until
					Result or l1.exhausted or l2.exhausted
				loop
					if
						not l1.item.date_time.is_equal (
												l2.item.date_time)
					then
						Result := true
					end
					l1.forth; l2.forth
				end
				if not Result and l1.exhausted /= l2.exhausted then
					Result := true
				end
			else
				check
					both_void_or_one_empty_and_false:
						((l1 = Void and l2 = Void) or else
							(l1.empty or l2.empty)) and not Result
				end
			end
		ensure
			void_gives_false: (l1 = Void and l2 = Void) implies (Result = false)
		end

	line_up (t1, t2: LINEAR [MARKET_TUPLE]) is
			-- Line up t1 and t2 so that they start on the same time period.
		require
			not_empty: not t1.empty and not t2.empty
		local
			l1, l2: LINEAR [MARKET_TUPLE]
		do
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

feature {FACTORY} -- Status setting

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
			parameter_list := Void
			processed_date_time := Void
		ensure
			functions_set: input1 = f1 and input2 = f2 and
							input1 /= Void and input2 /= Void
			output_empty: output.empty
			parameter_list_void: parameter_list = Void
			not_processed: not processed
		end

feature {NONE}

	input1, input2: MARKET_FUNCTION

	immediate_parameters: LIST [FUNCTION_PARAMETER] is
		once
		end

	parameter_list: LINKED_LIST [FUNCTION_PARAMETER]

invariant

	processed_constraint1:
		 processed implies input1.processed and input2.processed
	inputs_not_void: input1 /= Void and input2 /= Void
	target2_not_void: target2 /= Void
	input_target_relation:
		input1.output = target1 and input2.output = target2
	no_missing_periods: processed implies not missing_periods (target1, target2)
	inputs_trading_period_types_equal:
		input1.trading_period_type = input2.trading_period_type

end -- class TWO_VARIABLE_FUNCTION
