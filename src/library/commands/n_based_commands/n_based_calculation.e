indexing
	description:
		"Calculation based on the n-value from an n-record structure";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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

	initialize (arg: ANY) is
		local
			nstruct: N_RECORD_STRUCTURE
		do
			nstruct ?= arg
			if nstruct /= Void then
				set_n (nstruct.n)
			end
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
