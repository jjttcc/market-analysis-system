indexing
	description: 
		"A market function that takes one argument or variable"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ONE_VARIABLE_FUNCTION inherit

	COMPLEX_FUNCTION

	LINEAR_ANALYZER
		export {NONE}
			set_target
		redefine
			action
		end

creation {FACTORY}

	make

feature {NONE} -- Initialization

	make (in: like input; op: like operator) is
		require
			in_not_void: in /= Void
			op_not_void_if_used: operator_used implies op /= Void
			in_output_not_void: in.output /= Void
		do
			!!output.make (in.output.count)
			set_input (in)
			if op /= Void then
				set_operator (op)
			end
		ensure
			set: input = in and operator = op
		end

feature -- Access

	trading_period_type: TIME_PERIOD_TYPE is
		do
			Result := input.trading_period_type
		ensure then
			Result = input.trading_period_type
		end

	short_description: STRING is
		once
			Result := "Indicator that operates on a data sequence"
		end

	full_description: STRING is
		do
			!!Result.make (25)
			Result.append (short_description)
			Result.append (":%N")
			Result.append (input.full_description)
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
					input_parameters_not_void: input.parameters /= Void
				end
				parameter_set.fill (input.parameters)
				parameter_list.append (parameter_set)
			end
			Result := parameter_list
		end

feature -- Status report

	processed: BOOLEAN is
		do
			Result := input.processed and then
						processed_date_time /= Void and then
						processed_date_time >= input.processed_date_time
		end

feature {NONE}

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (target.item)
			!!t.make (target.item.date_time, operator.value)
			output.extend (t)
		ensure then
			output.count = old (output.count) + 1
		end

	do_process is
			-- Execute the function.
		do
			do_all
		end

	pre_process is
		do
			if not output.empty then
				output.wipe_out
			end
			if not input.processed then
				input.process
			end
		ensure then
			input_processed: input.processed
		end

feature {NONE}

	input: MARKET_FUNCTION

feature {FACTORY} -- Status setting

	set_input (in: like input) is
		require
			in_not_void: in /= Void and in.output /= Void
			output_not_void: output /= Void
		do
			input := in
			set_target (input.output)
			output.wipe_out
			parameter_list := Void
			processed_date_time := Void
		ensure
			input_set_to_in: input = in
			output_empty: output.empty
			parameter_list_void: parameter_list = Void
			not_processed: not processed
		end

invariant

	processed_constraint: processed implies input.processed
	input_not_void: input /= Void
	input_target_relation: input.output = target

end -- class ONE_VARIABLE_FUNCTION
