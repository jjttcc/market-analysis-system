indexing
	description: "A basic market tuple with a volume attribute";
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_TUPLE inherit

	BASIC_MARKET_TUPLE

feature -- Access

	volume: INTEGER
			-- Number of shares

end -- class VOLUME_TUPLE
