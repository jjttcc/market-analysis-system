indexing
	description:
		"A function that outputs an array of market tuples.  Specifications %
		%for function input are provided by descendant classes."
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_FUNCTION inherit

	FACTORY
		rename
			product as output
		export {NONE}
			execute -- not used
		redefine
			output
		end

feature -- Access

	name: STRING
			-- function name

	short_description: STRING is
			-- short description of the function
		do
			Result := "Stub: to be defined"
		end

	full_description: STRING is
			-- full description of the function, including descriptions
			-- of contained functions, if any
		do
			Result := "Stub: to be defined"
		end

	output: MARKET_TUPLE_LIST [MARKET_TUPLE] is
			-- y of function "y = f(x)"
		deferred
		end

	operator: NUMERIC_COMMAND
			-- operator that will perform the main work of the function.
			-- Descendant classes may choose not to use this attribute for
			-- efficiency.

	operator_used: BOOLEAN is
			-- Is operator used by this function?
		once
			Result := true
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		deferred
		end

feature -- Basic operations

	process is
			-- Process the output from the input.
		require
			not_processed: not processed
			opset_if_opused: operator_used implies operator /= Void
		do
			do_process
			set_processed (true)
		ensure
			processed: processed
		end

feature {FACTORY} -- Administration

	set_operator (op: NUMERIC_COMMAND) is
		require
			not_void: op /= Void
		do
			operator := op
		ensure
			op_set: operator = op and operator /= Void
		end

	set_name (n: STRING) is
			-- Set the function's name to n.
		require
			not_void: n /= Void
		do
			name := n
		ensure
			is_set: name = n and name /= Void
		end

feature {NONE}

	reset_state is
			-- Reset to initial state.
			-- Can be redefined if needed.
		do
			set_processed (false)
		ensure
			not_processed: not processed
		end

	do_process is
			-- Do the actual processing.
			-- Hook method to be defined by descendants
		deferred
		end

	set_processed (b: BOOLEAN) is
			-- Hook method to set processed state to the specified value
		deferred
		ensure
			is_set: processed = b
		end

feature {NONE} -- Not used

	execute (arg: ANY) is
		do
		end

invariant

	if_processed_output_exists: processed implies output /= Void
	op_used_constraint: processed implies (operator_used = (operator /= Void))

end -- class MARKET_FUNCTION
