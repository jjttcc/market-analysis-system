indexing
	description: "Volume tuple with open interest";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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
