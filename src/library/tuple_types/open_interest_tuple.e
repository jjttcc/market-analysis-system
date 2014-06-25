note
	description: "Volume tuple with open interest";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class OPEN_INTEREST_TUPLE inherit

	VOLUME_TUPLE

feature -- Access

	open_interest: DOUBLE
			-- Number of existing contracts
		deferred
		end

invariant

	oi_ge_0: open_interest >= 0

end -- class OPEN_INTEREST_TUPLE
