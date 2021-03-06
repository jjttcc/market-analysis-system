note
	description:
		"Calculations based on the n-value from an n-record structure";
	note1: "The calculation is done by `make' and by `initialize'.";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class N_BASED_CALCULATION inherit

	N_RECORD_COMMAND
		redefine
			set_n, initialize
		end

feature {FACTORY} -- Initialization

	set_n (i: like n)
		do
			Precursor (i)
			-- Calculate is called here for efficiency, since in most
			-- cases descendants will keep the empty execute implementation.
			value := calculate
		ensure then
			value = calculate
		end

	initialize (arg: ANY)
		local
			nstruct: N_RECORD_STRUCTURE
		do
			nstruct ?= arg
			if nstruct /= Void then
				set_n (nstruct.n)
			end
		end

feature -- Status report

	arg_mandatory: BOOLEAN = False

feature -- Basic operations

	execute (arg: ANY)
			-- Does nothing.
		do
			-- Empty
		end

feature {NONE} -- Implmentation

	calculate: DOUBLE
			-- Perform the calculation based on n.
		deferred
		end

end -- class N_BASED_CALCULATION
