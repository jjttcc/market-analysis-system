indexing
	description: 
		"An abstraction for a numeric command that produces the high %
		%price for the current trading period (extracted from the argument %
		%to the execute routine)"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class HIGH_PRICE inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute
		end

feature -- Basic operations

	execute (arg: BASIC_MARKET_TUPLE) is
		do
			value := arg.high.value
		ensure then
			value = arg.high.value
		end

end -- class HIGH_PRICE
