indexing
	description:
		"A basic numeric command that produces the open interest for the %
		%current trading period."
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class OPEN_INTEREST inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute
		end

feature -- Basic operations

	execute (arg: OPEN_INTEREST_TUPLE) is
			-- Can be redefined by ancestors.
		do
			value := arg.open_interest
		ensure then
			value = arg.open_interest
		end

end -- class OPEN_INTEREST
