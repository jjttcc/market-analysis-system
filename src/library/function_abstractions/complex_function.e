indexing
	description:
		"A market function that takes the result of another market function %
		%as input"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class COMPLEX_FUNCTION inherit

	MARKET_FUNCTION
		redefine
			immediate_operators
		end

feature -- Access

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]

	operator: RESULT_COMMAND [REAL]
			-- Operator that will perform the main work of the function.
			-- Descendant classes may choose not to use this attribute for
			-- efficiency.

	processed_date_time: DATE_TIME

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
			Result := clone (direct_parameters)
			Result.append (operator_parameters)
		end

feature -- Status report

	operator_used: BOOLEAN is
		once
			Result := True
		end

feature -- Basic operations

	process is
			-- Process the output from the input.
		do
			if
True or --!!!!For experimentation/testing - remove this line soon.
				not processed then
				pre_process
				if debugging then
					print_debugging_header
				end
				do_process
--!!!:
print ("complex function, name: " + name +
": process - do_process was just called." + "%N")
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
		local
			util: expanded GENERAL_UTILITIES
		do
			if processed_date_time = Void then
				processed_date_time := util.now_date_time
			else
				processed_date_time.make_now
			end
		end

	print_current_record_info is
		do
			if not output.is_empty then
				io.error.print ("Output record " + output.count.out +
					", date/time: " + output.last.date_time.out +
					", value: " + output.last.value.out + "%N")
			end
		end

	direct_operators: LIST [COMMAND] is
			-- All operators directly attached to Current
		do
			create {LINKED_LIST [COMMAND]} Result.make
			if operator /= Void then
				Result.extend (operator)
			end
		ensure
			exists: Result /= Void
			has_operator_if_it_exists:
				operator /= Void implies Result.has (operator)
		end

feature {MARKET_FUNCTION} -- Status report

	is_complex: BOOLEAN is True

feature {NONE} -- Implementation

	immediate_operators: LIST [COMMAND] is
		local
			direct_ops: LIST [COMMAND]
		do
			create {LINKED_LIST [COMMAND]} Result.make
			direct_ops := direct_operators
			from
				direct_ops.start
			invariant
				result_contains_previous_direct_op_and_descendants:
					direct_ops.valid_index (direct_ops.index - 1) implies
					Result.has (direct_ops @ (direct_ops.index - 1)) and
					(direct_ops @ (direct_ops.index - 1)).descendants.for_all (
						agent Result.has (?))
			variant
				direct_ops.count - direct_ops.index + 1
			until
				direct_ops.exhausted
			loop
				Result.extend (direct_ops.item)
				Result.append (direct_ops.item.descendants)
				direct_ops.forth
			end
		end

	print_status_report is
		local
			ops: LIST [COMMAND]
		do
			print_current_record_info
			if operator_used then
				ops := direct_operators
				from ops.start until ops.exhausted loop
					io.error.print (ops.item.status_report)
					ops.forth
				end
			end
		end

	print_debugging_header is
			-- Print debugging header information for the beginning
			-- of processing
		local
			util: expanded GENERAL_UTILITIES
		do
			io.error.print ("Processing data with " + name + " (at " +
				util.now_date_time.out + ").%N")
		end

invariant

	op_used_constraint: operator_used implies operator /= Void
	trading_period_type_not_void: trading_period_type /= Void

end -- class COMPLEX_FUNCTION
