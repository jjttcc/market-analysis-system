indexing
	description:
		"An abstraction for a numeric command that produces the opening %
		%price for the current trading period (extracted from the argument %
		%to the execute routine)"
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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
