indexing
	description: 
		"A market function that is also an array of market tuples. %
		%Its purpose is to act as the innermost function in a composition %
		%of functions."
	note: "Procedure process does nothing."
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_FUNCTION [G->MARKET_TUPLE] inherit

	MARKET_FUNCTION
		undefine
			is_equal, copy, setup
		redefine
			output, operator_used
		end

	MARKET_TUPLE_LIST [G]
		export {NONE}
			all
				{FACTORY}
			extend
				{ANY}
			sorted_by_date_time
		end

creation {FACTORY}

	make

feature -- Access

	output: MARKET_TUPLE_LIST [G] is
		do
			Result := Current
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		do
			Result := output /= Void
		ensure then
			Result = (output /= Void)
		end

	operator_used: BOOLEAN is
		once
			Result := false
		ensure then
			not_used: Result = false
		end

	arg_used: BOOLEAN is false

feature -- Basic operations

	do_process is
			-- Null action
		do
		end

end -- class SIMPLE_FUNCTION
