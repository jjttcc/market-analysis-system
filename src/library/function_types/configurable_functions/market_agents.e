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
		param, i: INTEGER
	do
print ("test_function start%N")
		create Result.make (0)
		l := f.inputs
		if f.operator /= Void then
			op := f.operator
		else
			create {BASIC_NUMERIC_COMMAND} op
		end
		if
			not f.parameters.is_empty and
			f.parameters.first.current_value.is_integer
		then
			param := f.parameters.first.current_value.to_integer
print ("Using f's parameter%N")
		else
			param := 10 -- Default value
print ("Using default parameter%N")
		end
print ("param was set to " + param.out + "%N")
		if not l.is_empty and then not l.first.output.is_empty then
			ml := l.first.output
			from
				from
					ml.start
					i := 1; sum := 0
				until
					i = param or ml.exhausted
				loop
					op.execute (ml.item)
					sum := sum + op.value
					ml.forth
					i := i + 1
				end
				op.execute (ml.item)
				sum := sum + op.value
				Result.extend (create {SIMPLE_TUPLE}.make (ml.item.date_time,
					ml.item.end_date, sum / param))
				if not ml.exhausted then ml.forth end
			until
				ml.exhausted
			loop
				op.execute (ml.i_th (ml.index - param))
				expired_value := op.value
				op.execute (ml.item)
				latest_value := op.value
				sum := sum - expired_value + latest_value
				Result.extend (create {SIMPLE_TUPLE}.make (ml.item.date_time,
					ml.item.end_date, sum / param))
				ml.forth
			end
		end
print ("test_function end%N")
	end

	functions: HASH_TABLE [FUNCTION [ANY, TUPLE [AGENT_BASED_FUNCTION],
		MARKET_TUPLE_LIST [MARKET_TUPLE]], INTEGER] is
			-- Table of available "market-agent" functions
		once
			create Result.make (0)
			Result.put (agent sma, Sma_key)
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

	Sma_key: INTEGER is unique

invariant

	functions_exist: functions /= Void

end
