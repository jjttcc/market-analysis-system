indexing
	description: 
		"An abstraction for a numeric command that produces the closing %
		%price for the current trading period (extracted from the argument %
		%to the execute routine)"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class CLOSING_PRICE inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute
		end

feature -- Basic operations

	execute (arg: BASIC_MARKET_TUPLE) is
		do
			value := arg.close.value
		ensure then
			value = arg.close.value
		end

end -- class CLOSING_PRICE
