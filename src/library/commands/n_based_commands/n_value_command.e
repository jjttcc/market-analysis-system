indexing
	description:
		"A command that simply gives as its `value', the value of its %
		%`n' feature";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class N_VALUE_COMMAND inherit

	N_BASED_CALCULATION

creation

	make

feature {NONE} -- Implmentation

	calculate: REAL is
			-- Perform the calculation based on n.
		do
			Result := n
		end

end -- class N_VALUE_COMMAND
