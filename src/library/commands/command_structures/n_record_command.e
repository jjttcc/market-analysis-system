indexing
	description:
		"An numeric command that is also an n-record command"
	date: "$Date$";
	revision: "$Revision$"

deferred class N_RECORD_COMMAND inherit

	NUMERIC_COMMAND
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
			--!!!set_owner (arg)
		ensure then
			n_set_to_argn: n = arg.n
		end

end -- class N_RECORD_COMMAND
