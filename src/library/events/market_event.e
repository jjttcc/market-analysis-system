indexing
	description:
		"An event associated with a market such as a stock or bond"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_EVENT inherit

	TYPED_EVENT

feature -- Access

	start_date, end_date: DATE_TIME is
		deferred
		end

invariant

	start_date <= end_date

end -- class MARKET_EVENT
