indexing
	description:
		"A numeric command that operates on a market tuple (passed in via %
		%the execute feature)."
	date: "$Date$";
	revision: "$Revision$"

class BASIC_NUMERIC_COMMAND inherit

	NUMERIC_COMMAND

feature -- Basic operations

	execute (arg: MARKET_TUPLE) is
			-- Sets its value from arg's value
			-- Can be redefined by ancestors.
		do
			value := arg.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is true

end -- class BASIC_NUMERIC_COMMAND
