indexing
	description:
		"Calculation based on the n-value from an n-record structure";
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class N_BASED_CALCULATION inherit

	N_RECORD_COMMAND
		redefine
			set_n, initialize
		end

feature {FACTORY} -- Initialization

	set_n (i: like n) is
		do
			Precursor (i)
			-- Calculate is called here for efficiency, since in most
			-- cases descendants will keep the empty execute implementation.
			value := calculate
		ensure then
			value = calculate
		end

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			set_n (arg.n)
		ensure then
			new_n: n = arg.n
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

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
