note
	description: "So-called moving average exponentials"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MA_EXPONENTIAL inherit

	N_BASED_CALCULATION

creation

	make

feature {NONE}

	calculate: DOUBLE
		do
			Result := 2 / (n + 1)
		end

end -- class MA_EXPONENTIAL
