indexing
	description:
		"A function that outputs an array of market tuples.  Specifications %
		%for function input are provided by descendant classes."
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_FUNCTION inherit

	FACTORY
		rename
			product as output, execute as process,
			execute_precondition as process_precondition
		redefine
			output, process_precondition
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

feature -- Status report

	operator_used: BOOLEAN is
			-- Is operator used by this function?
		deferred
		end

	processed: BOOLEAN is
			-- Has this function been processed?
		deferred
		end

	process_precondition: BOOLEAN is
		do
			Result := not processed and
						(operator_used implies operator /= Void)
		ensure then
			not_processed_and_opset_if_opused:
				Result implies
					not processed and (operator_used implies operator /= Void)
		end

feature -- Basic operations

	process (arg: ANY) is
			-- Process the output from the input.
		do
			pre_process
			do_process
		ensure then
			processed: processed
		end

feature {FACTORY} -- Element change

	set_operator (op: NUMERIC_COMMAND) is
		require
			not_void: op /= Void
			ready_to_execute: op.execute_precondition
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

feature {NONE} -- Hook methods

	pre_process is
			-- Do any pre-processing required before calling do_process.
		do
		end

	do_process is
			-- Do the actual processing.
			-- Hook method to be defined by descendants
		deferred
		end

invariant

	output_not_void: output /= Void
	op_used_constraint: operator_used implies operator /= Void

end -- class MARKET_FUNCTION
