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

	sma (f: AGENT_BASED_FUNCTION): MARKET_TUPLE_LIST [MARKET_TUPLE] is
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

	standard_deviation (f: AGENT_BASED_FUNCTION):
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
			if f.inputs.count < 1 then
				-- !!! Report error condition.
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
--print (avg.out + " " + sos.out + " " + math.sqrt(sos / n).out + "%N")
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
--print (avg.out + " " + sos.out + " " + math.sqrt(sos / n).out + "%N")
					Result.extend (create {SIMPLE_TUPLE}.make (
						ml.item.date_time, ml.item.end_date,
						math.sqrt (sos / n)))
					ml.forth
				end
			end
print ("standard_deviation end%N")
		end

	functions: HASH_TABLE [FUNCTION [ANY, TUPLE [AGENT_BASED_FUNCTION],
		MARKET_TUPLE_LIST [MARKET_TUPLE]], INTEGER] is
			-- Table of available "market-agent" functions
		once
			create Result.make (0)
			Result.put (agent sma, Sma_key)
			Result.put (agent standard_deviation, Standard_deviation_key)
		end

	infix "@" (key: INTEGER): FUNCTION [ANY, TUPLE [AGENT_BASED_FUNCTION],
		MARKET_TUPLE_LIST [MARKET_TUPLE]] is
			-- Current.functions @ key, for convenience
		do
			Result := functions @ key
		ensure
			definition: Result = functions @ key
		end

feature -- Agent keys

	Sma_key, Standard_deviation_key: INTEGER is unique

feature {NONE} -- Utilities

	sum_of_squares (starti, n: INTEGER; avg: DOUBLE;
			values: ARRAYED_LIST [DOUBLE]): DOUBLE is
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
				Result := Result + (values @ i - avg) ^ 2
				j := j + 1; i := i + 1
			end
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

	functions_exist: functions /= Void

end

--awk 'BEGIN {
--n = 5
--i = 1
--}
--{
--	printf("%s ", $2)
--}
--(NR <= n) {
--	sum += $2
--	values[i++] = $2
--	if (NR == n) {
--		avg = sum / n
--		sos = sum_of_squares(1, avg)
--		printf("%0.4f %0.4f %0.4f\n",  avg, sos, sqrt(sos / n))
--	} else print ""
--	next
--}
--{
--	sum += $2
--#	print "subtracted " values[i-n] " (" i " - " n " = " i - n ")"
--	sum -= values[i-n]
--	values[i++] = $2
--	avg = sum / n
--	sos = sum_of_squares(i - n, avg)
--	printf("%0.4f %0.4f %0.4f\n",  avg, sos, sqrt(sos / n))
--}
--
--function sum_of_squares(starti, avg, sum, i, j) {
--#print "sos called"
--	sum = 0
--	i = starti; j = 1
--	while (j <= n) {
--		sum += (values[i] - avg) ^ 2
--		++j; ++i
--	}
--	return sum
--' $*
