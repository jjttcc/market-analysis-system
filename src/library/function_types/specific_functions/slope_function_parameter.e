indexing
	description:
		"Changeable slope parameter for MARKET_FUNCTION_LINE"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SLOPE_FUNCTION_PARAMETER inherit

	FUNCTION_PARAMETER
		redefine
			function
		end

creation {MARKET_FUNCTION}

	make

feature -- Access

	function: MARKET_FUNCTION_LINE

	current_value: REAL_REF is
		do
			Result := function.slope
		end

	name: STRING is "slope"

feature -- Element change

	change_value (new_value: REAL_REF) is
		do
			function.set_slope (new_value.item)
		end

feature -- Basic operations

	valid_value (i: REAL_REF): BOOLEAN is
		do
			Result := true
		end

end -- class SLOPE_FUNCTION_PARAMETER
