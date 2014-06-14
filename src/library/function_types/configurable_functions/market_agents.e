note
	description:
		"Selection of agents for use in AGENT_BASED_FUNCTION"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_AGENTS inherit

	GENERAL_UTILITIES

	MARKET_FUNCTION_EDITOR

feature -- Access

	infix "@" (key: STRING): PROCEDURE [ANY, TUPLE [AGENT_BASED_FUNCTION]]
			-- Current.agents @ key, for convenience
		do
			Result := agents @ key
		ensure
			definition: Result = agents @ key
		end

	keys: ARRAY [STRING]
			-- Available agent keys
-- !!!! indexing once_status: global??!!! [probably]
		once
			Result := <<Sma_key, Standard_deviation_key>>
			Result.compare_objects
		ensure
			object_comparison: Result.object_comparison
		end

	parameters_for (key: STRING): LINKED_SET [FUNCTION_PARAMETER]
			-- Function parameters associated with `key'
		require
			valid_key: key /= Void and then keys.has (key)
		do
			Result := agent_parameter_map @ key
		ensure
			result_exists: Result /= Void
		end

	agent_parameter_map: HASH_TABLE [LINKED_SET [FUNCTION_PARAMETER], STRING]
			-- Mapping of each agent key to its associated
			-- FUNCTION_PARAMETER set
		local
			fp_set: LINKED_SET [FUNCTION_PARAMETER]
-- !!!! indexing once_status: global??!!!
		once
			create Result.make (0)
			create fp_set.make
			fp_set.extend (create {INTEGER_FUNCTION_PARAMETER}.make (
				Sma_fp_default))
			Result.put (fp_set, Sma_key)
			create fp_set.make
			fp_set.extend (create {INTEGER_FUNCTION_PARAMETER}.make (
				Standard_deviation_fp_default))
			Result.put (fp_set, Standard_deviation_key)
		ensure
			result_exists: Result /= Void
		end

feature -- Agents

	sma (f: AGENT_BASED_FUNCTION)
			-- Simple moving average
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		do
			n_based_accumulation (f, integer_parameter_value (f, 10), agent
				sum_divided_by_n, addition_operator, subtraction_operator)
		end

	standard_deviation (f: AGENT_BASED_FUNCTION)
			-- Standard deviation
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		do
			debug ("std_dev")
				print ("std dev called with f.name: " + f.name + "%N")
			end
			n_based_accumulation (f, integer_parameter_value (f, 5),
				agent sum_of_squares_of_avg_divided_by_n, addition_operator,
				subtraction_operator)
		end

feature -- Agent keys

	Sma_key: STRING = "Simple moving average"

	Standard_deviation_key: STRING = "Standard deviation"

feature {NONE} -- Algorithm implementations used by agents

--@@Put this operation into its own class (N_BASED_ACCUMULATION)
--with settable parameters, similar to INTEGRAL or SUM under
--work/experiments/sicp/integral.  If so, it may be a good idea to
--add a 'filter' function that must be true before a value is used
--in the accumulation.  (See
--http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-12.html#%_thm_1.33)
--Utility instances of this class can be created as attributes or
--once functions - for example, addition_accumulation', whose combiner
--(accum_op) and drop_off_op operators are ADDITION and SUBTRACTION,
--respectively.
	n_based_accumulation (f: AGENT_BASED_FUNCTION; n: INTEGER;
		calculation: FUNCTION [ANY, TUPLE [DOUBLE, INTEGER,
		ARRAYED_LIST [DOUBLE]], DOUBLE]; accum_op, drop_off_op:
		BINARY_OPERATOR [DOUBLE, DOUBLE])
			-- An "accumulation" - whose input is `f.inputs.first.output' -
			-- based on applying the specified function, `calculation', to
			-- n-sized subsets of the elements of the input (for example,
			-- a moving average calculation), using `accum_op' as the
			-- intermediary "accumulation" operator (for example, addition,
			-- for a moving average), and `drop_off_op' to "drop-off" the
			-- last "obsolete" value ("extracted" using `f.operator', or
			-- a BASIC_NUMERIC_COMMAND, if `f.operator' is Void).
			-- When `accum_op' is addition, 'drop_off_op' will usually be
			-- subtraction - that is, the obsolete value - the
			-- (current_index - n)th value - is subtracted to maintain
			-- the sum of the last n values.
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		local
			ml: LIST [MARKET_TUPLE]
			extraction_operator: RESULT_COMMAND [DOUBLE]
			current_value, latest_extracted_value, initial_value: DOUBLE
			values: ARRAYED_LIST [DOUBLE]
		do
			create values.make (0); initial_value := 0
			-- @@Note: initial_value needs to be made configurable.
			check_objects (<<f.inputs>>, <<"indicator">>,
				agent has_elements (?, 1), agent handle_invalid_state, Void,
				"has no input function")
			check_objects (<<f.inputs.first>>, <<"input function">>,
				agent output_not_empty, agent handle_invalid_state,
				Void, "is empty")
-- @@@!!!###%%%Fix/work needed here:
-- !!!!!!!!!!!!Needs fixing - commented out temporarily for E 5.6 compile:
--			check_objects (<<n>>, <<"n value">>,
--				agent greater_than (?, 1), agent handle_invalid_state,
--				Void, "is not greater than 1")
			ml := f.inputs.first.output
			if f.operator /= Void then
				extraction_operator := f.operator
			else
				create {BASIC_NUMERIC_COMMAND} extraction_operator
			end
			from
				from
					ml.start
					current_value := initial_value
				invariant
					values_ml_index_relation1: values.count + 1 = ml.index
				until
					ml.index = n or ml.exhausted
				loop
					extraction_operator.execute (ml.item)
					current_value := binary_double_operation (accum_op,
						current_value, extraction_operator.value)
					values.extend (extraction_operator.value)
					ml.forth
				end
				if not ml.exhausted then
					extraction_operator.execute (ml.item)
					current_value := binary_double_operation (accum_op,
						current_value, extraction_operator.value)
					values.extend (extraction_operator.value)
					f.output.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date,
						calculation.item ([current_value, n, values])))
					ml.forth
					check
						values_ml_index_relation2:
							values.count + 1 = ml.index
					end
				end
			invariant
				values_ml_index_relation3: values.count + 1 = ml.index
			until
				ml.exhausted
			loop
				extraction_operator.execute (ml.item)
				latest_extracted_value := extraction_operator.value
				current_value := binary_double_operation (accum_op,
					current_value, latest_extracted_value)
				current_value := binary_double_operation (drop_off_op,
					current_value, values.i_th (ml.index - n))
				values.extend (latest_extracted_value)
				f.output.extend (create {SIMPLE_TUPLE}.make (
					ml.item.date_time, ml.item.end_date,
					calculation.item ([current_value, n, values])))
				ml.forth
			end
		end

feature {NONE} -- COMMAND-based utility routines

	binary_double_operation (op: BINARY_OPERATOR [DOUBLE, DOUBLE];
		x, y: DOUBLE): DOUBLE
		require
			op_exists: op /= Void
			no_arg_needed: not op.arg_mandatory
		do
			x_value.set_value (x)
			y_value.set_value (y)
			op.set_operands (x_value, y_value)
			op.execute (Void)
			Result := op.value
		end

	x_value: NUMERIC_VALUE_COMMAND
			-- Value for `x' used in binary operation - optimization
		do
			if x_value_implementation = Void then
				create x_value_implementation.make (0)
			end
			Result := x_value_implementation
		end

	y_value: NUMERIC_VALUE_COMMAND
			-- Value for `y' used in binary operation - optimization
		do
			if y_value_implementation = Void then
				create y_value_implementation.make (0)
			end
			Result := y_value_implementation
		end

	addition_operator: ADDITION
		do
			if addition_operator_implementation = Void then
				create addition_operator_implementation.make (
					x_value, y_value)
			end
			Result := addition_operator_implementation
		end

	subtraction_operator: SUBTRACTION
		do
			if subtraction_operator_implementation = Void then
				create subtraction_operator_implementation.make (
					x_value, y_value)
			end
			Result := subtraction_operator_implementation
		end

	x_value_implementation, y_value_implementation: NUMERIC_VALUE_COMMAND

	addition_operator_implementation: ADDITION

	subtraction_operator_implementation: SUBTRACTION

feature {NONE} -- Implementation

	agents: HASH_TABLE [PROCEDURE [ANY, TUPLE [AGENT_BASED_FUNCTION]],
		STRING]
			-- Table of available "market-agents"
-- !!!! indexing once_status: global??!!!
		once
			create Result.make (0)
			Result.put (agent sma, Sma_key)
			Result.put (agent standard_deviation, Standard_deviation_key)
		end

feature {NONE} -- Utilities

--@@These can perhaps go into a separate class (perhaps MARKET_UTILITIES).
	sum_of_squares (starti, n: INTEGER; avg: DOUBLE;
			values: ARRAYED_LIST [DOUBLE]): DOUBLE
		require
			starti_valid: starti + n - 1 <= values.count
		local
			i, j: INTEGER
		do
			from
				Result := 0
				i := starti; j := 1
			until
				j > n
			loop
				Result := Result + (values @ i - avg) ^ 2
				j := j + 1; i := i + 1
			end
		end

	sum_of_squares_of_avg_divided_by_n (sum: DOUBLE; n: INTEGER;
		values: ARRAYED_LIST [DOUBLE]): DOUBLE
			-- Sum of squares of sum / n, using `values'
		local
			avg, sos: DOUBLE
			math: expanded DOUBLE_MATH
		do
			avg := sum / n
			sos := sum_of_squares (values.count + 1 - n, n, avg, values)
			Result := math.sqrt (sos / n)
		end

	sum_divided_by_n (sum: DOUBLE; n: INTEGER; values: ARRAYED_LIST [DOUBLE]):
		DOUBLE
			-- `sum' / `n'
		do
			Result := sum / n
		end

	integer_parameter_value (f: AGENT_BASED_FUNCTION; deflt: INTEGER):
		INTEGER
			-- f's first immediate integer parameter value if it exists -
			-- otherwise, `deflt'
		local
			plist: LIST [FUNCTION_PARAMETER]
		do
			Result := -1
			plist := f.immediate_parameters
			from
				plist.start
			until
				Result /= -1 or plist.exhausted
			loop
				if
					plist.item.current_value.is_integer
				then
					Result := plist.item.current_value.to_integer
				end
				plist.forth
			end
			if Result = -1 then
				Result := deflt
			end
		end

	has_elements (l: LIST [MARKET_FUNCTION]; n: INTEGER): BOOLEAN
			-- Does `l' have at least `n' elements?
		do
			Result := l /= Void and then l.count >= n
		end

	output_not_empty (f: MARKET_FUNCTION): BOOLEAN
			-- Is `f.output' not empty?
		do
			Result := not f.output.is_empty
		end

	greater_than (target, n: INTEGER): BOOLEAN
			-- Is `target' greater than `n'?
		do
			Result := target > n
		end

	handle_invalid_state (l: LIST [STRING]; arg: ANY; info: STRING)
			-- Handle an invalid state that occurred during processing.
		local
			ex_srv: expanded EXCEPTION_SERVICES
		do
			ex_srv.last_exception_status.set_fatal (True)
			ex_srv.handle_exception (info)
		end

feature {NONE} -- Constants

	Sma_fp_default: INTEGER = 13
			-- Default function-parameter value for the `sma' agent

	Standard_deviation_fp_default: INTEGER = 5
			-- Default function-parameter value for the
			-- `standard_deviation' agent

invariant

	agents_exist: agents /= Void

end
