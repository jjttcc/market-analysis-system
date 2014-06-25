note
	description: "Volume tuple with open interest redefined as an attribute";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class BASIC_OPEN_INTEREST_TUPLE inherit

	BASIC_VOLUME_TUPLE

	OPEN_INTEREST_TUPLE

creation

	make

feature -- Access

	open_interest: DOUBLE
			-- Number of existing contracts

feature {VALUE_SETTER} -- Status setting

	set_open_interest (i: DOUBLE)
			-- Set open_interest to `i'.
		require
			i >= 0
		do
			open_interest := i
		ensure
			open_interest = i
		end

end -- class BASIC_OPEN_INTEREST_TUPLE
