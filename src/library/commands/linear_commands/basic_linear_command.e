indexing
	description:
		"A numeric command that operates on the current item of a linear%
		%structure of market tuples"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_LINEAR_COMMAND inherit

	NUMERIC_COMMAND

feature -- Basic operations

	execute (arg: ANY) is
				-- Can be redefined by ancestors.
		do
			value := input.item.value
		end

feature -- Element change (export to ??)

	set_input (in: LINEAR [MARKET_TUPLE]) is
		require
			in /= Void
		do
			input := in
		ensure
			input = in
		end

feature {NONE}

	input: LINEAR [MARKET_TUPLE]

end -- class BASIC_LINEAR_COMMAND
