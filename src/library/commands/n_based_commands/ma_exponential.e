indexing
	description: "So-called moving average exponential"

class MA_EXPONENTIAL inherit

	N_BASED_CALCULATION

feature

	calculate (n: REAL): REAL is
		do
			Result := 2 / (n + 1)
		end

end -- class MA_EXPONENTIAL
