indexing
	description: "Miscellaneous information about a derivative instrument";
NOTE: Not used any more - move to obsolete directory.
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class DERIVATIVE_DATA

feature -- Access

	symbol: STRING

	name: STRING is
			-- Name of instrument associated with `symbol'
		deferred
		end

	description: STRING is
			-- Description of instrument associated with `symbol'
		deferred
		end

feature -- Status setting

	set_symbol (arg: STRING) is
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

end -- class DERIVATIVE_DATA
