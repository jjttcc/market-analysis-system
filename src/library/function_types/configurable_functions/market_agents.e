indexing
	description:
		"Selection of agents for use in AGENT_BASED_FUNCTION"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	MARKET_AGENTS

feature -- Access

	infix "@" (key: INTEGER): PROCEDURE [ANY, TUPLE [AGENT_BASED_FUNCTION]] is
			-- Current.agents @ key, for convenience
		do
			Result := agents @ key
		ensure
			definition: Result = agents @ key
		end

feature -- Access

	sma (f: AGENT_BASED_FUNCTION) is
			-- Standard moving average
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		do
--!!!Test: Change to call n_based_calculation.
			sma_based_calculation (f, agent sum_divided_by_n)
		end

	standard_deviation (f: AGENT_BASED_FUNCTION) is
			-- Standard deviation
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		do
--!!!Test: Change to call n_based_calculation.
			sma_based_calculation (f, agent sum_of_squares_of_avg_divided_by_n)
		end

	sma_based_calculation (f: AGENT_BASED_FUNCTION; calculation: FUNCTION [
		ANY, TUPLE [DOUBLE, INTEGER, ARRAYED_LIST [DOUBLE]], DOUBLE]) is
			-- Calculation that follows the pattern of a
			-- standard moving average calculation, using an agent to
			-- allow some degree of configuration
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		local
			ml: LIST [MARKET_TUPLE]
			op: RESULT_COMMAND [REAL]
			sum, latest_value: DOUBLE
			n: INTEGER
			values: ARRAYED_LIST [DOUBLE]
		do
			create values.make (0)
			if f.inputs.is_empty or else f.inputs.first.output.is_empty then
				if f.inputs.is_empty then
					-- !!! Report error condition.
				end
			else
				n := integer_parameter_value (f, 10)
				ml := f.inputs.first.output
				if f.operator /= Void then
					op := f.operator
				else
					create {BASIC_NUMERIC_COMMAND} op
				end
				from
					from
						ml.start
						sum := 0
					invariant
						values_ml_index_relation1: values.count + 1 = ml.index
					until
						ml.index = n or ml.exhausted
					loop
						op.execute (ml.item)
						sum := sum + op.value
						values.extend (op.value)
						ml.forth
					end
					if not ml.exhausted then
						op.execute (ml.item)
						sum := sum + op.value
						values.extend (op.value)
						f.output.extend (create {SIMPLE_TUPLE}.make (
							ml.item.date_time, ml.item.end_date,
							calculation.item ([sum, n, values])))
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
					op.execute (ml.item)
					latest_value := op.value
					sum := sum - values.i_th (ml.index - n) + latest_value
					values.extend (latest_value)
					f.output.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date,
						calculation.item ([sum, n, values])))
					ml.forth
				end
			end
		end

--!!!For compile-testing
call_n_based_calculation is
 do
	n_based_calculation (Void, 0, Void, agent addition, agent subtraction)
 end

addition (x, y: DOUBLE): DOUBLE is do Result := x + y end
subtraction (x, y: DOUBLE): DOUBLE is do Result := x - y end

	n_based_calculation (f: AGENT_BASED_FUNCTION; n: INTEGER;
		main_function: FUNCTION [ANY, TUPLE [DOUBLE, INTEGER,
		ARRAYED_LIST [DOUBLE]], DOUBLE]; accumulation_function:
		FUNCTION [ANY, TUPLE [DOUBLE, DOUBLE], DOUBLE];
		drop_off_function:
		FUNCTION [ANY, TUPLE [DOUBLE, DOUBLE], DOUBLE]) is
			-- !!!Calculation that ...
			-- `drop_off_function' is used to "drop-off" the last "obsolete"
			-- calculation; when accumulation_function is addition, this
			-- will usually be subtraction - i.e., the obsolete value,
			-- the (current_index - n)th value is subtracted to maintain
			-- the sum of the last n values.
			--!!!Describe what main_function, drop_off_function,
			--and accumulation_function are.
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		local
			ml: LIST [MARKET_TUPLE]
			extraction_operator: RESULT_COMMAND [REAL]
			current_value, latest_value: DOUBLE
			values: ARRAYED_LIST [DOUBLE]
		do
			create values.make (0)
			if
				f.inputs.is_empty or else f.inputs.first.output.is_empty or
				n <= 1
			then
				if f.inputs.is_empty then
					-- !!! Report error condition.
				end
				if n <= 1 then
					-- !!! Report error condition.
				end
			else
--				n := integer_parameter_value (f, 10)
				ml := f.inputs.first.output
				if f.operator /= Void then
					extraction_operator := f.operator
				else
					create {BASIC_NUMERIC_COMMAND} extraction_operator
				end
				from
					from
						ml.start
						current_value := 0
					invariant
						values_ml_index_relation1: values.count + 1 = ml.index
					until
						ml.index = n or ml.exhausted
					loop
						extraction_operator.execute (ml.item)
						current_value := accumulation_function.item (
							[current_value, extraction_operator.value])
						values.extend (extraction_operator.value)
						ml.forth
					end
					if not ml.exhausted then
						extraction_operator.execute (ml.item)
						current_value := accumulation_function.item (
							[current_value, extraction_operator.value])
						values.extend (extraction_operator.value)
						f.output.extend (create {SIMPLE_TUPLE}.make (
							ml.item.date_time, ml.item.end_date,
							main_function.item ([current_value, n, values])))
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
					latest_value := extraction_operator.value
					current_value := accumulation_function.item (
						[current_value, latest_value])
					current_value := drop_off_function.item ([current_value,
						values.i_th (ml.index - n)])
					values.extend (latest_value)
					f.output.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date,
						main_function.item ([current_value, n, values])))
					ml.forth
				end
			end
		end

feature {NONE} -- Implementation

	agents: HASH_TABLE [PROCEDURE [ANY, TUPLE [AGENT_BASED_FUNCTION]],
		INTEGER] is
			-- Table of available "market-agents"
		once
			create Result.make (0)
			Result.put (agent sma, Sma_key)
			Result.put (agent standard_deviation, Standard_deviation_key)
		end

feature -- Agent keys

	Sma_key, Standard_deviation_key: INTEGER is unique

feature {NONE} -- !!!!!What to call these???

	binary_double_operation (op: BINARY_OPERATOR [REAL, REAL];
		x, y: DOUBLE): DOUBLE is
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

	x_value: CONSTANT is
			-- Value for `x' used in binary operation - optimization
		do
			if x_value_implementation = Void then
				create x_value_implementation.make (0)
			end
			Result := x_value_implementation
		end

	y_value: CONSTANT is
			-- Value for `y' used in binary operation - optimization
		do
			if y_value_implementation = Void then
				create y_value_implementation.make (0)
			end
			Result := y_value_implementation
		end

	default_binary_operator: ADDITION is
		do
			if default_binary_operator_implementation = Void then
				create default_binary_operator_implementation.make (
					x_value, y_value)
			end
			Result := default_binary_operator_implementation
		end

	x_value_implementation, y_value_implementation: CONSTANT

	default_binary_operator_implementation: ADDITION

feature {NONE} -- Utilities

	sum_of_squares (starti, n: INTEGER; avg: DOUBLE;
			values: ARRAYED_LIST [DOUBLE]): DOUBLE is
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
		values: ARRAYED_LIST [DOUBLE]): DOUBLE is
			-- Sum of squares of sum / n, using `values'
		local
			avg, sos: DOUBLE
			math: expanded SINGLE_MATH
		do
			avg := sum / n
			sos := sum_of_squares (values.count + 1 - n, n, avg, values)
			Result := math.sqrt (sos / n)
		end

	sum_divided_by_n (sum: DOUBLE; n: INTEGER; values: ARRAYED_LIST [DOUBLE]):
		DOUBLE is
			-- `sum' / `n'
		do
			Result := sum / n
		end

	integer_parameter_value (f: AGENT_BASED_FUNCTION; deflt: INTEGER):
		INTEGER is
			-- f's first parameter value if it exists and is an integer -
			-- otherwise, deflt
		do
			if
				not f.parameters.is_empty and
				f.parameters.first.current_value.is_integer
			then
				Result := f.parameters.first.current_value.to_integer
			else
				Result := deflt
			end
		end

feature {NONE} -- Old, out-of-date features that should soon be removed!!!

	old_sma (f: AGENT_BASED_FUNCTION): MARKET_TUPLE_LIST [MARKET_TUPLE] is
			-- Standard moving average
		local
			ml: LIST [MARKET_TUPLE]
			l: LIST [MARKET_FUNCTION]
			op: RESULT_COMMAND [REAL]
			sum, latest_value, expired_value: DOUBLE
			n, i: INTEGER
		do
			create Result.make (0)
			l := f.inputs
			if f.operator /= Void then
				op := f.operator
			else
				create {BASIC_NUMERIC_COMMAND} op
			end
			n := integer_parameter_value (f, 10)
			if not l.is_empty and then not l.first.output.is_empty then
				ml := l.first.output
				from
					from
						ml.start
						i := 1; sum := 0
					until
						i = n or ml.exhausted
					loop
						op.execute (ml.item)
						sum := sum + op.value
						ml.forth
						i := i + 1
					end
					op.execute (ml.item)
					sum := sum + op.value
					Result.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date, sum / n))
					if not ml.exhausted then ml.forth end
				until
					ml.exhausted
				loop
					op.execute (ml.i_th (ml.index - n))
					expired_value := op.value
					op.execute (ml.item)
					latest_value := op.value
					sum := sum - expired_value + latest_value
					Result.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date, sum / n))
					ml.forth
				end
			end
		end

	old_standard_deviation (f: AGENT_BASED_FUNCTION):
		MARKET_TUPLE_LIST [MARKET_TUPLE] is
			-- Standard deviation
		local
			ml: LIST [MARKET_TUPLE]
			op: RESULT_COMMAND [REAL]
			sum, latest_value, avg, sos: DOUBLE
			n: INTEGER
			values: ARRAYED_LIST [DOUBLE]
			math: expanded SINGLE_MATH
		do
			create Result.make (0)
			create values.make (0)
			if f.inputs.is_empty or else f.inputs.first.output.is_empty then
				if f.inputs.is_empty then
					-- !!! Report error condition.
				end
			else
				n := integer_parameter_value (f, 5)
				ml := f.inputs.first.output
				if f.operator /= Void then
					op := f.operator
				else
					create {BASIC_NUMERIC_COMMAND} op
				end
				from
					from
						ml.start
						sum := 0
					until
						ml.index = n or ml.exhausted
					loop
						op.execute (ml.item)
						sum := sum + op.value
						values.extend (op.value)
						ml.forth
					end
					op.execute (ml.item)
					sum := sum + op.value
					values.extend (op.value)
					avg := sum / n
					sos := sum_of_squares (1, n, avg, values)
					Result.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date,
						math.sqrt (sos / n)))
					if not ml.exhausted then ml.forth end
				until
					ml.exhausted
				loop
					op.execute (ml.item)
					latest_value := op.value
					sum := sum - values.i_th (ml.index - n) + latest_value
					values.extend (latest_value)
					avg := sum / n
					sos := sum_of_squares (ml.index + 1 - n, n, avg, values)
					Result.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date,
						math.sqrt (sos / n)))
					ml.forth
				end
			end
		end

invariant

	agents_exist: agents /= Void

end
