indexing
	description:
		"Calculation based on the n-value from an n-record structure";
	date: "$Date$";
	revision: "$Revision$"

deferred class N_BASED_CALCULATION inherit

	NUMERIC_COMMAND
		redefine
			initialize, execute_precondition
		end

	N_RECORD_STRUCTURE

feature -- Initialization

	initialize (s: N_RECORD_STRUCTURE) is
			-- Initialize value with n from s
		require else
			s.n_set
		do
			set_n (s.n)
			-- Calculate is called here for efficiency, since in most
			-- cases descendants will keep the empty execute implementation.
			value := calculate
		ensure then
			value = calculate
			n_set: n_set
			n_set_to_s_n: n = s.n
		end

feature -- Status report

	arg_used: BOOLEAN is
		do
			Result := false
		ensure then
			not_used: Result = false
		end

	execute_precondition: BOOLEAN is
		do
			Result := n_set
		ensure then
			n_set: Result = n_set
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			-- Empty
		end

feature {NONE} -- Implmentation

	calculate: REAL is
			-- Perform the calculation based on n.
		require
			n_set: n_set
		deferred
		end

end -- class N_BASED_CALCULATION
