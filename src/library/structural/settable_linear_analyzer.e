indexing
	description: 
		"An abstraction that provides services for processing sequential %
		%structure of market tuples."
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

feature {NONE}

	target: LINEAR [MARKET_TUPLE]

end -- class LINEAR_ANALYZER
