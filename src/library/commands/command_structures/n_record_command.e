indexing
	description:
		"A result command that is also an n-record structure"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class N_RECORD_COMMAND inherit

	RESULT_COMMAND [REAL]
		export
			{MARKET_FUNCTION} initialize
		redefine
			initialize
		end

	N_RECORD_STRUCTURE
		export
			{COMMAND_EDITOR} set_n
		end

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

	initialize (arg: ANY) is
			-- If `arg' conforms to N_RECORD_STRUCTURE, set `n' to arg.n.
		local
			ns: N_RECORD_STRUCTURE
		do
			ns ?= arg
			if ns /= Void then
				set_n (ns.n)
			end
		end

end -- class N_RECORD_COMMAND
