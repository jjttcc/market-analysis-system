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

	old_sma (f: AGENT_BASED_FUNCTION): MARKET_TUPLE_LIST [MARKET_TUPLE] is
			-- Standard moving average
		local
			ml: LIST [MARKET_TUPLE]
			l: LIST [MARKET_FUNCTION]
			op: RESULT_COMMAND [REAL]
			sum, latest_value, expired_value: DOUBLE
			n, i: INTEGER
		do
print ("test_function start%N")
			create Result.make (0)
			l := f.inputs
			if f.operator /= Void then
				op := f.operator
			else
				create {BASIC_NUMERIC_COMMAND} op
			end
			n := integer_parameter_value (f, 10)
print ("param was set to " + n.out + "%N")
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
print ("test_function end%N")
		end

	sma (f: AGENT_BASED_FUNCTION) is
			-- Standard moving average
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		do
print ("sma called%N")
			sma_based_calculation (f, agent sum_divided_by_n)
		end

	standard_deviation (f: AGENT_BASED_FUNCTION) is
			-- Standard deviation
		require
			f_output_empty: f.output /= Void and f.output.is_empty
		do
print ("standard_deviation called%N")
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
print ("sma_based_calculation start%N")
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
print ("sma_based_calculation end%N")
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
print ("standard_deviation start%N")
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
print ("standard_deviation end%N")
		end

	agents: HASH_TABLE [PROCEDURE [ANY, TUPLE [AGENT_BASED_FUNCTION]],
		INTEGER] is
			-- Table of available "market-agents"
		once
			create Result.make (0)
			Result.put (agent sma, Sma_key)
			Result.put (agent standard_deviation, Standard_deviation_key)
		end

	infix "@" (key: INTEGER): PROCEDURE [ANY, TUPLE [AGENT_BASED_FUNCTION]] is
			-- Current.agents @ key, for convenience
		do
			Result := agents @ key
		ensure
			definition: Result = agents @ key
		end

feature -- Agent keys

	Sma_key, Standard_deviation_key: INTEGER is unique

feature {NONE} -- Utilities

	sum_of_squares (starti, n: INTEGER; avg: DOUBLE;
			values: ARRAYED_LIST [DOUBLE]): DOUBLE is
		require
			starti_valid: starti + n - 1 <= values.count
		local
			i, j: INTEGER
		do
--print ("sos - starti: " + starti.out + " (n: " + n.out + ")%N")
--print ("sos - values.count: " + values.count.out + "%N")
			from
				Result := 0
				i := starti; j := 1
			until
				j > n
			loop
--print ("i, j: " + i.out + ", " + j.out + "%N")
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
--print ("sum_of_squares_of_avg_divided_by_n called%N")
			avg := sum / n
--print ("sum, n, avg: " + sum.out + ", " + n.out + ", " + avg.out + "%N")
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
print ("Using f's parameter%N")
			else
				Result := deflt
print ("Using default parameter%N")
			end
		end

invariant

	agents_exist: agents /= Void

end