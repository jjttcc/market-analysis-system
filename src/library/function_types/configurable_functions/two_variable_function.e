indexing
	description: 
		"A market function that takes two arguments or variables"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TWO_VARIABLE_FUNCTION

inherit

	COMPLEX_FUNCTION

	TWO_VARIABLE_LINEAR_ANALYZER
		redefine
			action
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

feature -- Status report

	processed: BOOLEAN is
		do
			Result := (input1.processed and input2.processed) and then
					processed_date_time /= Void and then
					processed_date_time >= input1.processed_date_time and then
					processed_date_time >= input2.processed_date_time
		end

feature {NONE} -- Hook methods

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (Void)
			check
				t1_t2_dates_equal: target1.item.date_time.is_equal (
									target2.item.date_time)
			end
			!!t.make (target1.item.date_time, operator.value)
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

invariant

	processed_constraint1:
		 processed implies input1.processed and input2.processed
	inputs_not_void: input1 /= Void and input2 /= Void
	input_target_relation:
		input1.output = target1 and input2.output = target2
	no_missing_periods: processed implies not missing_periods (target1, target2)
	inputs_trading_period_types_equal:
		input1.trading_period_type = input2.trading_period_type

end -- class TWO_VARIABLE_FUNCTION
