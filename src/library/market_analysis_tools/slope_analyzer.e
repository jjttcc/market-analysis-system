note
	description:
		"A linear analyzer that determines the slope of the current item"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	make (tgt: like target)
		require
			not_void: tgt /= Void
		do
			set (tgt)
		ensure
			target = tgt
		end

feature -- Status report

	arg_mandatory: BOOLEAN = False

	target_cursor_not_affected: BOOLEAN = True
			-- True

feature -- Basic operations

	execute (arg: ANY)
		do
			value := slope (target)
		end

end -- class SLOPE_ANALYZER
