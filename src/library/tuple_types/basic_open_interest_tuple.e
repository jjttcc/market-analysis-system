indexing
	description: "Volume tuple with open interest redefined as an attribute";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class BASIC_OPEN_INTEREST_TUPLE inherit

	BASIC_VOLUME_TUPLE

	OPEN_INTEREST_TUPLE

creation

	make

feature -- Access

	open_interest: INTEGER
			-- Number of existing contracts

feature {VALUE_SETTER} -- Status setting

	set_open_interest (i: INTEGER) is
			-- Set open_interest to `i'.
		require
			i >= 0
		do
			open_interest := i
		ensure
			open_interest = i
		end

end -- class BASIC_OPEN_INTEREST_TUPLE
