indexing
	description: "So-called moving average exponential"
	date: "$Date$";
	revision: "$Revision$"

class MA_EXPONENTIAL inherit

	N_BASED_CALCULATION

feature {NONE}

	calculate: REAL is
		do
			Result := 2 / (n + 1)
		end

end -- class MA_EXPONENTIAL
