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

	N_RECORD_STRUCTURE
		redefine
			set_n
		end

feature {FACTORY} -- Initialization --!!!Check export

	make (i: like n) is
		require
			i_gt_0: i > 0
		do
			set_n (i)
		ensure
			n_set: n = i
		end

	initialize (s: N_RECORD_STRUCTURE) is
			-- Initialize value with n from s
		do
			set_n (s.n)
		ensure then
			value = calculate
			n_set_to_s_n: n = s.n
		end

feature {FACTORY} -- Initialization --!!!Check export

	set_n (i: like n) is
		do
			Precursor (i)
			-- Calculate is called here for efficiency, since in most
			-- cases descendants will keep the empty execute implementation.
			value := calculate
		ensure then
			value = calculate
		end

feature -- Status report

	arg_used: BOOLEAN is false

feature -- Basic operations

	execute (arg: ANY) is
		do
			-- Empty
		end

feature {NONE} -- Implmentation

	calculate: REAL is
			-- Perform the calculation based on n.
		deferred
		end

end -- class N_BASED_CALCULATION
