indexing
	description: 
		"An abstraction that provides services for processing a sequential %
		%structure of market tuples."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class LINEAR_ANALYZER

inherit

	LINEAR_ITERATOR [MARKET_TUPLE]
		export
			{NONE} all
		redefine
			target
		end

feature {FACTORY} -- Status setting

	set_target (in: CHAIN [MARKET_TUPLE]) is
		require
			not_void: in /= Void
		do
			target := in
		ensure then
			target_set: target = in and target /= Void
		end

feature {NONE}

	target: CHAIN [MARKET_TUPLE]

invariant

	target_not_void: target /= Void

end -- class LINEAR_ANALYZER
