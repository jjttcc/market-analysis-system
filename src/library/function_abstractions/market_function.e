indexing
	description: 
		"A function that outputs an array of market tuples.  Specifications for function%
		%input are provided by descendant classes."

deferred class MARKET_FUNCTION

feature -- Initialization

	make is
		do
			!!output.make (0) -- What size to use here?
		end

feature -- Access

	name: STRING
			-- function name

	output: ARRAYED_LIST [MARKET_TUPLE]
			-- y of function "y = f(x)"

feature -- Status report

	processed: BOOLEAN
			-- Has this function been processed?

feature -- Basic operations

	process is
			-- Process the output from the input.
		require
			not processed
		deferred
		ensure
			processed
		end

feature -- {FINANCE_ROOT} -- Element change -- Export to test class for now.

	set_operator (op: NUMERIC_COMMAND) is
		require
			not_void: op /= Void
		do
			operator := op
		ensure
			operator = op
		end

feature {NONE} -- Implementation

	operator: NUMERIC_COMMAND
			-- operator that will perform the main work of the function.
			-- Descendant classes may choose not to use this attribute for
			-- efficiency.


end -- class MARKET_FUNCTION
