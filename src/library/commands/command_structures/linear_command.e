indexing
	description: "A result command that is also a linear analyzer"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class LINEAR_COMMAND inherit

	RESULT_COMMAND [REAL]
		export {MARKET_FUNCTION}
			initialize
		redefine
			execute
		end

	LINEAR_ANALYZER
		export {NONE}
			all
				{FACTORY}
			set_target
		end

feature -- Basic operations

	execute (arg: ANY) is
		deferred
		ensure then
			target_cursor_internal_contract:
			target_cursor_not_affected = (target.index = old target.index)
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN is
			-- Will target.index change when execute is called?
		deferred
		end

end -- class LINEAR_COMMAND
