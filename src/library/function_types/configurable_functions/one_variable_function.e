indexing
	description: 
		"A market function that takes two arguments or variables%
		%(that is, analyzes two vectors)."
	date: "$Date$";
	revision: "$Revision$"

class ONE_VECTOR_FUNCTION inherit

	MARKET_FUNCTION

	VECTOR_ANALYZER
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

feature -- Basic operations

	do_process is
			-- Execute the function.
			-- {Note to self:  It seems logical to export this feature
			-- and processed to everyone so that outside control is allowed,
			-- for efficiency, as to when the function is processed.  Two
			-- alternatives are to export to NONE and have the function itself
			-- call these functions (that is, if not processed then process end)
			-- or to export to a designated class that manages this.}
		do
			do_all
		end

feature

	output: ARRAYED_LIST [MARKET_TUPLE]

	processed: BOOLEAN

feature {NONE}

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (target.item)
			!!t
			t.set_value (operator.value)
			output.extend (t)
		end

feature {NONE}

	input: MARKET_FUNCTION

feature {NONE}

	set_processed (b: BOOLEAN) is
		do
			processed := b
		end

feature {TEST_FUNCTION_FACTORY} -- Element change

	set_input (in: MARKET_FUNCTION) is
		do
			input := in
			target := input.output
			reset_state
		ensure
			not_processed: not processed
		end

end -- class ONE_VECTOR_FUNCTION
