indexing
	description:
		"An abstraction for a numeric command that produces the high %
		%price for the current trading period (extracted from the argument %
		%to the execute routine)"
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
