indexing
	description:
		"Calculation based on the n-value from an n-record structure";
	date: "$Date$";
	revision: "$Revision$"

deferred class N_BASED_CALCULATION inherit

	NUMERIC_COMMAND
		redefine
			initialize
		end

feature -- Initialization

	initialize (s: n_record_structure) is
			-- Initialize value with n from s
		do
			value := calculate (s.n)
		ensure then
			value = calculate (s.n)
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			-- Empty
		end

feature {NONE} -- Implmentation

	calculate (n: REAL): REAL is
			-- Perform the calculation based on n.
		deferred
		end

end -- class N_BASED_CALCULATION
