indexing
	description: 
		"A market function that takes one argument or variable"
	date: "$Date$";
	revision: "$Revision$"

class ONE_VARIABLE_FUNCTION inherit

	MARKET_FUNCTION

	LINEAR_ANALYZER
		redefine
			action
		end

creation

	make

feature -- Initialization

	make is
		do
			!!output.make (100) -- !!What size to use here?
		end

feature

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]

	processed: BOOLEAN

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
			-- output.count = old (output.count) + 1
		end

	do_process is
			-- Execute the function.
		do
			do_all
		end

feature {NONE}

	input: MARKET_FUNCTION

feature {NONE}

	set_processed (b: BOOLEAN) is
		do
			processed := b
		end

feature {TEST_FUNCTION_FACTORY} -- Element change

	set_input (in: like input) is
		require
			not_void: in /= Void and in.output /= Void
		do
			input := in
			set_target (input.output)
			reset_state
		ensure
			input_set_to_in: input = in
			input_set: target_set
			not_processed: not processed
		end

invariant

	processed_constraint: processed implies input.processed
	input_target_relation: input = Void or else input.output = target

end -- class ONE_VARIABLE_FUNCTION
