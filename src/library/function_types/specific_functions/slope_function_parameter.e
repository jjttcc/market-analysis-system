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

	current_value: INTEGER is
		do
			Result := function.slope.floor
		end

	name: STRING is "slope"

feature -- Element change

	change_value (new_value: INTEGER) is
		do
			function.set_slope (new_value)
		end

feature -- Basic operations

	valid_value (i: INTEGER): BOOLEAN is
		do
			Result := true
		end

end -- class SLOPE_FUNCTION_PARAMETER
