indexing
	description: "A result command that is also a linear analyzer"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class LINEAR_COMMAND inherit

	RESULT_COMMAND [REAL]
		export {MARKET_FUNCTION}
			initialize
		redefine
			execute, initialize
		end

	LINEAR_ANALYZER
		export
			{NONE} all
			{COMMAND_EDITOR, MARKET_FUNCTION_EDITOR} set
		end

feature -- Initialization

	initialize (a: LINEAR_ANALYZER) is
		do
			set (a.target)
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
			-- Will target.index not change when execute is called?
		deferred
		end

end -- class LINEAR_COMMAND
