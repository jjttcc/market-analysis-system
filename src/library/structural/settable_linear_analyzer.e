indexing
	description:
		"An abstraction that provides services for processing a sequential %
		%structure of market tuples."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class LINEAR_ANALYZER

inherit

	LINEAR_ITERATOR [MARKET_TUPLE]
		export
			{NONE} all
		redefine
			target
		end

feature {FACTORY, COMMAND} -- Status setting

	set_target (in: CHAIN [MARKET_TUPLE]) is
		require
			not_void: in /= Void
		do
			target := in
		ensure then
			target_set: target = in and target /= Void
		end

feature {FACTORY, COMMAND}

	target: CHAIN [MARKET_TUPLE]

invariant

	target_not_void: target /= Void

end -- class LINEAR_ANALYZER
