indexing
	description: 
		"A market function that takes two arguments or variables%
		%(that is, analyzes two vectors)."

class TWO_VECTOR_FUNCTION

inherit

	MARKET_FUNCTION

	VECTOR_ANALYZER
		rename
			input as input1, -- x in "z = f(x, y)"
			set_input as set_input1
		redefine
			forth, action, start
		select
			input1, set_input1, forth, action, start
		end

	VECTOR_ANALYZER
		rename
			input as input2, -- y in "z = f(x, y)"
			set_input as set_input_unused,
			forth as forth_unused,
			action as action_unused,
			start as start_unused
		export {NONE}
			set_input_unused, forth_unused, action_unused
		end

creation

	make

feature -- Basic operations

	process is
		do
			do_all
			processed := true
		end

feature {NONE}

	forth is
		do
			input1.forth
			input2.forth
		end

	start is
		do
			input1.start
			input2.start
		end

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (Void)
			!!t
			t.set_value (operator.value)
			output.extend (t)
		end

	reset_state is
		do
			processed := false
		end

feature {FINANCE_ROOT} -- Element change (Export to test class for now.)

	set_input2 (the_input: ARRAYED_LIST [MARKET_TUPLE]) is
			-- Set input2 vector to `the_input'.
		require
			not_void: the_input /= Void
		do
			input2 := the_input
			reset_state
		ensure
			input2 = the_input
		end

end -- class TWO_VECTOR_FUNCTION
