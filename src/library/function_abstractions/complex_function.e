indexing
	description:
		"A market function that takes the result of another market function %
		%as input"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class COMPLEX_FUNCTION inherit

	MARKET_FUNCTION

feature -- Access

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]

	operator: RESULT_COMMAND [REAL]
			-- Operator that will perform the main work of the function.
			-- Descendant classes may choose not to use this attribute for
			-- efficiency.

	processed_date_time: DATE_TIME

feature -- Status report

	operator_used: BOOLEAN is
		once
			Result := true
		end

feature -- Basic operations

	process is
			-- Process the output from the input.
		do
			if not processed then
				pre_process
				do_process
				update_processed_date_time
			end
			debug
				print (name); print (" just became processed, output size: ")
				print (output.count); print ("%N")
			end
		end

feature {MARKET_FUNCTION_EDITOR} -- Status setting

	set_operator (op: like operator) is
		require
			not_void: op /= Void
		do
			operator := op
		ensure
			op_set: operator = op and operator /= Void
		end

feature {NONE} -- Hook methods

	pre_process is
			-- Do any pre-processing required before calling do_process.
		require
			not_processed: not processed
		deferred
		ensure
			output_empty: output.empty
		end

	do_process is
			-- Do the actual processing.
			-- Hook method to be defined by descendants
		require
			output_empty: output.empty
		deferred
		end

	update_processed_date_time is
		do
			if processed_date_time = Void then
				!!processed_date_time.make_now
			else
				processed_date_time.make_now
			end
		end

feature {MARKET_FUNCTION} -- Status report

	is_complex: BOOLEAN is true

feature {NONE} -- Implementation

	parameter_list: LINKED_LIST [FUNCTION_PARAMETER]

	immediate_parameters: LIST [FUNCTION_PARAMETER] is
		once
		end

invariant

	op_used_constraint: operator_used implies operator /= Void

end -- class COMPLEX_FUNCTION
