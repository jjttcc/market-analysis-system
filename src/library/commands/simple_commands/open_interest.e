indexing
	description:
		"A basic numeric command that produces the open interest for the %
		%current trading period."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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
