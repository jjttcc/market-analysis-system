indexing
	description:
		"A market function that takes the result of another market function %
		%as input"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class COMPLEX_FUNCTION inherit

	MARKET_FUNCTION
		redefine
			operators
		end

feature -- Access

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]

	operator: RESULT_COMMAND [REAL]
			-- Operator that will perform the main work of the function.
			-- Descendant classes may choose not to use this attribute for
			-- efficiency.

	processed_date_time: DATE_TIME

	operators: LIST [COMMAND] is
		do
			if operator /= Void then
				Result := operator_and_descendants (operator)
			else
				create {LINKED_LIST [COMMAND]} Result.make
			end
		end

	leaf_functions: LIST [COMPLEX_FUNCTION] is
			-- All of Current's innermost, or leaf, COMPLEX_FUNCTIONs -
			-- At least one because a complex function without any children
			-- will be its own leaf function.
		deferred
		ensure
			at_least_one: Result /= Void and then Result.count >= 1
		end

	parameters: LIST [FUNCTION_PARAMETER] is
		do
			if parameter_list = Void then
				parameter_list := main_parameters
				parameter_list.append (command_parameters)
			end
			Result := parameter_list
		end

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
			output_empty: output.is_empty
		end

	do_process is
			-- Do the actual processing.
			-- Hook method to be defined by descendants
		require
			output_empty: output.is_empty
		deferred
		end

	update_processed_date_time is
			-- Update `processed_date_time' to now - can be used by
			-- descendants as part of `processed' implementation and
			-- redefined if needed.
		do
			if processed_date_time = Void then
				create processed_date_time.make_now
			else
				processed_date_time.make_now
			end
		end

feature {MARKET_FUNCTION} -- Status report

	is_complex: BOOLEAN is true

feature {NONE} -- Implementation

	parameter_list: LINKED_LIST [FUNCTION_PARAMETER]

	immediate_parameters: LIST [FUNCTION_PARAMETER] is
--!!!!NOTE: This feature is not redefined in several descendants.  Since
--it is a once function, that could be a problem (bug).  Check it out.
--NOTE2: A brief review leads me to suspect there is no problem; but
--it should be checked out more thoroughly before deleting this warning.
		once
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
		end

	operator_and_descendants (op: COMMAND): LIST [COMMAND] is
			-- Operator `op' and all of its descendants
		require
			op_not_void: op /= Void
		do
			create {LINKED_LIST [COMMAND]} Result.make
			Result.extend (op)
			Result.append (op.descendants)
		end

	command_parameters: LIST [FUNCTION_PARAMETER] is
		local
			ops: LIST [COMMAND]
		do
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
			if operators /= Void then
				from
					ops := operators
					ops.start
				until
					ops.exhausted
				loop
					if ops.item.is_editable then
						ops.item.prepare_for_editing (Result)
					end
					ops.forth
				end
			end
		ensure
			result_exists: Result /= Void
		end

	main_parameters: LINKED_LIST [FUNCTION_PARAMETER] is
		deferred
		ensure
			result_exists: Result /= Void
		end

invariant

	op_used_constraint: operator_used implies operator /= Void
	trading_period_type_not_void: trading_period_type /= Void

end -- class COMPLEX_FUNCTION
