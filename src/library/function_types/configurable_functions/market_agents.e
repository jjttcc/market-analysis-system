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

	one_hundreds (l: LIST [MARKET_FUNCTION]):
		MARKET_TUPLE_LIST [MARKET_TUPLE] is
			-- Simple function for testing - give result of list of 100s
	local
		ml: LIST [MARKET_TUPLE]
	do
print ("test_function start%N")
		create Result.make (0)
		if not l.is_empty and then not l.first.output.is_empty then
			ml := l.first.output
			from ml.start until ml.exhausted loop
				Result.extend (create {SIMPLE_TUPLE}.make (ml.item.date_time,
					ml.item.date_time.date, 100))
				ml.forth
			end
		end
print ("test_function end%N")
	end

	functions: HASH_TABLE [FUNCTION [ANY, TUPLE [LIST [MARKET_FUNCTION]],
		MARKET_TUPLE_LIST [MARKET_TUPLE]], INTEGER] is
			-- Table of available "market-agent" functions
		once
			create Result.make (0)
			Result.put (agent one_hundreds, One_hundreds_key)
		end

	infix "@" (key: INTEGER): FUNCTION [ANY, TUPLE [LIST [MARKET_FUNCTION]],
		MARKET_TUPLE_LIST [MARKET_TUPLE]] is
			-- Current.functions @ key, for convenience
		do
			Result := functions @ key
		ensure
			definition: Result = functions @ key
		end

feature -- Agent keys

	One_hundreds_key: INTEGER is unique

invariant

	functions_exist: functions /= Void

end -- class ONE_VARIABLE_FUNCTION
