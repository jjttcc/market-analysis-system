indexing
	description: 
		"A market function that provides a concept of an n-length%
		%sub-vector of the main input vector."

class N_RECORD_ONE_VECTOR_FUNCTION inherit

	MARKET_FUNCTION
		redefine
			output
		end

	VECTOR_ANALYZER
		redefine
			action
		end

	N_RECORD_STRUCTURE

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
		local
			i: INTEGER
		do
			input.go_i_th (n)
			continue_until
			processed := true
		end

feature

	output: ARRAYED_LIST [SIMPLE_TUPLE]

feature {NONE}

	reset_state is
		do
			processed := false
		end

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (input.item)
			!!t
			t.set_value (operator.value)
			output.extend (t)
		end

end -- class N_RECORD_ONE_VECTOR_FUNCTION
