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

feature -- Status report

	input_set: BOOLEAN is
			-- Has the input to be analyzed been set?
		do
			Result := target /= Void
		end

feature {FACTORY} -- Element change

	set_input (in: LINEAR [MARKET_TUPLE]) is
		require
			not_void: in /= Void
		do
			target := in
		ensure then
			target_set: target = in
			input_set: input_set
		end

feature {NONE}

	target: LINEAR [MARKET_TUPLE]

end -- class LINEAR_ANALYZER
