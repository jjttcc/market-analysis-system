indexing
	description: 
		"A market function that is also an array of market tuples. %
		%Its purpose is to act as the innermost function in a composition %
		%of functions."
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_FUNCTION [G->MARKET_TUPLE] inherit

	MARKET_FUNCTION
		undefine
			is_equal, copy, setup
		redefine
			output, reset_state, operator_used
		end

	ARRAYED_LIST [G]

creation

	make

feature -- Access

	output: ARRAYED_LIST [G] is
		do
			Result := Current
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		do
			Result := output /= Void
		end

feature -- Basic operations

	do_process is
			-- Null action
		do
		end

feature {NONE}

	reset_state is
			-- Null action
		do
		end

	set_processed (b: BOOLEAN) is
			-- Null action, since processed state cannot be set
		do
		end

	operator_used: BOOLEAN is
		once
			Result := false
		end

end -- class SIMPLE_FUNCTION
