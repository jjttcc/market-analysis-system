indexing
	description: 
		"A market function that provides a concept of an n-length%
		%sub-vector of the main input vector."
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_ONE_VECTOR_FUNCTION inherit

	ONE_VECTOR_FUNCTION
		redefine
			do_process, make, target
		end

	N_RECORD_STRUCTURE
		rename
			set_n as set_parent_n
		end

creation

	make

feature

	make is
		do
			init_n
			precursor
		end

feature -- Basic operations

	do_process is
			-- Execute the function.
		local
			i: INTEGER
		do
			target.go_i_th (n)
			continue_until
		end

feature {NONE}

	target: ARRAYED_LIST [MARKET_TUPLE]

feature {TEST_FUNCTION_FACTORY}

	set_n (i: INTEGER) is
		require
			operator_used implies operator /= Void
		do
			set_parent_n (i)
			if operator /= Void then
				operator.initialize (Current)
			end
		end

invariant

	n_positive: n >= 1

end -- class N_RECORD_ONE_VECTOR_FUNCTION
