indexing
	description:
		"A linear analyzer that determines the slope of the current item"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SLOPE_ANALYZER inherit

	MARKET_ANALYSIS
		export {NONE}
			all
		end

	LINEAR_COMMAND
		export {MARKET_FUNCTION}
			initialize
		end

creation

	make

feature -- Initialization

	make (tgt: like target) is
		require
			not_void: tgt /= Void
		do
			target := tgt
		ensure
			target = tgt
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

	target_cursor_not_affected: BOOLEAN is true
			-- True

feature -- Basic operations

	execute (arg: ANY) is
		do
			value := slope (target)
		end

end -- class SLOPE_ANALYZER
