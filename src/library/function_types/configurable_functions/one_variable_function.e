indexing
	description: 
		"A market function that takes one argument or variable"
	date: "$Date$";
	revision: "$Revision$"

class ONE_VARIABLE_FUNCTION inherit

	MARKET_FUNCTION
		redefine
			pre_process
		end

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

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]

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

feature -- Element change

feature -- Status report

	processed: BOOLEAN is
		do
			Result := input.processed and then
				(target.empty or not output.empty)
		end

	arg_mandatory: BOOLEAN is false

	operator_used: BOOLEAN is
		once
			Result := true
		end

feature {NONE}

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (target.item)
			!!t
			t.set_value (operator.value)
			t.set_date_time (target.item.date_time)
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
			if not input.processed then
				input.process (Void)
			end
		ensure then
			input_processed: input.processed
		end

feature {NONE}

	input: MARKET_FUNCTION

feature {FACTORY} -- Element change

	set_input (in: like input) is
		require
			in_not_void: in /= Void and in.output /= Void
			output_not_void: output /= Void
		do
			input := in
			set_target (input.output)
			output.wipe_out
		ensure
			input_set_to_in: input = in
			output_empty: output.empty
		end

invariant

	processed_constraint: processed implies input.processed
	input_not_void: input /= Void
	input_target_relation: input.output = target

end -- class ONE_VARIABLE_FUNCTION
