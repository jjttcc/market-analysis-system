indexing
	description: 
		"A linear analyzer that determines the slope of the current item"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SLOPE_ANALYZER inherit

	MARKET_ANALYSIS

	LINEAR_COMMAND

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

feature -- Basic operations

	execute (arg: ANY) is
		do
			value := slope (target)
		end

end -- class SLOPE_ANALYZER
