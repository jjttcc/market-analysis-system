indexing
	description: 
		"A market function that takes two arguments or variables%
		%(that is, analyzes two vectors)."
	date: "$Date$";
	revision: "$Revision$"

class ONE_VECTOR_FUNCTION inherit

	MARKET_FUNCTION
		redefine
			output
		end

	VECTOR_ANALYZER
		redefine
			action
		end

creation

	make

feature -- Basic operations

	process is
			-- Execute the function.
			-- {Note to self:  It seems logical to export this feature
			-- and processed to everyone so that outside control is allowed,
			-- for efficiency, as to when the function is processed.  Two
			-- alternatives are to export to NONE and have the function itself
			-- call these functions (that is, if not processed then process end)
			-- or to export to a designated class that manages this.}
		do
			do_all
			processed := true
		end

feature

	output: ARRAYED_LIST [SIMPLE_TUPLE]

feature {NONE}

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (input.item)
			!!t
			t.set_value (operator.value)
			output.extend (t)
		end

	reset_state is
		do
			processed := false
		end

end -- class ONE_VECTOR_FUNCTION
