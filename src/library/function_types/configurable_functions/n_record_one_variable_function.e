indexing
	description: 
		"A market function that provides a concept of an n-length %
		%sub-list of the main input list."
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_ONE_VARIABLE_FUNCTION inherit

	ONE_VARIABLE_FUNCTION
		redefine
			do_process, make, target, process_precondition
		end

	N_RECORD_STRUCTURE
		redefine
			set_n
		end

creation

	make

feature

	make is
		do
			Precursor
		end

feature -- Basic operations

	do_process is
			-- Execute the function.
		do
			target.go_i_th (n)
			continue_until
		end

feature -- Status report

	process_precondition: BOOLEAN is
		do
			Result := n_set and Precursor
		ensure then
			n_set: Result implies n_set
		end

feature {NONE}

	target: ARRAYED_LIST [MARKET_TUPLE]

feature {TEST_FUNCTION_FACTORY}

	set_n (i: INTEGER) is
		do
			Precursor (i)
			if operator /= Void then
				operator.initialize (Current)
			end
		end

end -- class N_RECORD_ONE_VARIABLE_FUNCTION
