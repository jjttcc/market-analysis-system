note
	description: "Volume tuple with open interest";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OPEN_INTEREST_TUPLE inherit

	VOLUME_TUPLE

feature -- Access

	open_interest: REAL
			-- Number of existing contracts
		deferred
		end

invariant

	oi_ge_0: open_interest >= 0

end -- class OPEN_INTEREST_TUPLE
