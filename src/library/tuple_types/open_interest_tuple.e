indexing
	description: "Volume tuple with open interest";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class OPEN_INTEREST_TUPLE inherit

	VOLUME_TUPLE

feature -- Access

	open_interest: INTEGER is
			-- Number of existing contracts
		deferred
		end

invariant

	oi_ge_0: open_interest >= 0

end -- class OPEN_INTEREST_TUPLE
