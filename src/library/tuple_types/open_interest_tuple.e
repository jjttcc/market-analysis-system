indexing
	description: "Volume tuple with open interest";
	date: "$Date$";
	revision: "$Revision$"

class OPEN_INTEREST_TUPLE inherit

	VOLUME_TUPLE

creation

	make

feature

	open_interest: INTEGER
			-- Number of existing contracts

feature {VALUE_SETTER} -- Element change

	set_open_interest (i: INTEGER) is
			-- Set open_interest to `i'.
		require
			i >= 0
		do
			open_interest := i
		ensure
			open_interest = i
		end

invariant

	oi_ge_0: open_interest >= 0

end -- class OPEN_INTEREST_TUPLE
