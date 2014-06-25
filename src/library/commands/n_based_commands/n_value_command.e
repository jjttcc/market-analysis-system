note
	description: "N-record commands that simply give as their `value', %
		%the value of their `n' feature";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class N_VALUE_COMMAND inherit

	N_BASED_CALCULATION

creation

	make

feature {NONE} -- Implmentation

	calculate: DOUBLE
			-- Perform the calculation based on n.
		do
			Result := n
		end

end -- class N_VALUE_COMMAND
