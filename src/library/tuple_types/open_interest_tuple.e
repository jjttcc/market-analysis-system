indexing
	description: "Volume tuple with open interest";
	date: "$Date$";
	revision: "$Revision$"

class OPEN_INTEREST_TUPLE inherit

	VOLUME_TUPLE

feature

	open_interest: INTEGER
			-- Number of existing contracts

end -- class OPEN_INTEREST_TUPLE
