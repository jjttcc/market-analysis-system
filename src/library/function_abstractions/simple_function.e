indexing
	description: 
		"A market function that is also an array of market tuples. %
		%Its purpose is to act as the innermost function in a composition %
		%of functions."
	question: "!!!Design has changed - should processed definition be removed?"
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
		rename
			make as arrayed_list_make
		export {NONE}
			all
				{FACTORY}
			extend
				{ANY}
			sorted_by_date_time
		end

creation {FACTORY}

	make

feature -- Initialization

	make (type: TIME_PERIOD_TYPE) is
		require
			not_void: type /= Void
		do
			trading_period_type := type
		ensure
			tpt_set: trading_period_type = type and trading_period_type /= Void
		end

feature -- Access

	output: MARKET_TUPLE_LIST [G] is
		do
			Result := Current
		end

	trading_period_type: TIME_PERIOD_TYPE

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

feature {NONE} -- Basic operations

	do_process is
			-- Null action
		do
		end

invariant

	trading_period_type_not_void: trading_period_type /= Void
end -- class SIMPLE_FUNCTION
