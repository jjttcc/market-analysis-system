indexing
	description:
		"An abstraction for a numeric command that produces the closing %
		%price for the current trading period (extracted from the argument %
		%to the execute routine)"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
