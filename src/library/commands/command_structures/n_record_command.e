indexing
	description:
		"A result command that is also an n-record structure"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class N_RECORD_COMMAND inherit

	RESULT_COMMAND [REAL]
		export {MARKET_FUNCTION}
			initialize
		redefine
			initialize
		end

	N_RECORD_STRUCTURE

feature -- Initialization

	make (i: like n) is
		require
			i_gt_0: i > 0
		do
			set_n (i)
		ensure
			set: n = i
		end

feature {MARKET_FUNCTION}

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			set_n (arg.n)
		ensure then
			n_set_to_argn: n = arg.n
		end

end -- class N_RECORD_COMMAND
