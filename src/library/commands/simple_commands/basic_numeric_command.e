indexing
	description:
		"A numeric command that operates on a market tuple that is passed in %
		%as an argument to the execute feature"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
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
