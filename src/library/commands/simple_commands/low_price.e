indexing
	description: 
		"An abstraction for a numeric command that produces the low %
		%price for the current trading period (extracted from the argument %
		%to the execute routine)"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class LOW_PRICE inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute
		end

feature -- Basic operations

	execute (arg: BASIC_MARKET_TUPLE) is
		do
			value := arg.low.value
		ensure then
			value = arg.low.value
		end

end -- class LOW_PRICE
