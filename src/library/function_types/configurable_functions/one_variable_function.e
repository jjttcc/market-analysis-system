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

creation

	make

feature -- Initialization

	make is
		do
			!!output.make (100) -- !!!What size to use here?
		end

feature -- Access

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]

feature -- Status report

	processed: BOOLEAN is
		do
			Result :=
						input = Void or --!!!Remove this line soon.
			input.processed and then
				(target.empty or not output.empty)
		ensure then
			processed_definition: Result = (input.processed and then
				(target.empty or not output.empty))
		end

	arg_used: BOOLEAN is false

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

feature {TEST_FUNCTION_FACTORY} -- Element change

	set_input (in: like input) is
		require
			not_void: in /= Void and in.output /= Void
			in_op_not_void_if_used:
				in.operator_used implies in.operator /= Void
		do
			input := in
			set_target (input.output)
			check output /= Void end
			output.wipe_out
		ensure
			input_set_to_in: input = in
			input_set: target_set
			output_empty: output.empty
		end

invariant

	--!!!Temp. comm-out: processed_constraint: processed implies input.processed
	input_target_relation: input = Void or else input.output = target

end -- class ONE_VARIABLE_FUNCTION
