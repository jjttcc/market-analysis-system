indexing
	description: "So-called moving average exponential"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MA_EXPONENTIAL inherit

	N_BASED_CALCULATION

creation

	make

feature {NONE}

	calculate: REAL is
		do
			Result := 2 / (n + 1)
		end

end -- class MA_EXPONENTIAL
