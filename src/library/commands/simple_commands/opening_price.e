indexing
	description: 
		"An abstraction for a numeric command that produces the opening %
		%price for the current trading period (extracted from the argument %
		%to the execute routine)"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class OPENING_PRICE inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute
		end

feature -- Basic operations

	execute (arg: BASIC_MARKET_TUPLE) is
		do
			value := arg.open.value
		ensure then
			value = arg.open.value
		end

end -- class OPENING_PRICE
