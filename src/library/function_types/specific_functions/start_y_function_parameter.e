indexing
	description:
		"Changeable start_y parameter for MARKET_FUNCTION_LINE"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class START_Y_FUNCTION_PARAMETER inherit

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
			Result := function.start_y.floor
		end

	name: STRING is "y-value for the left-most point"

feature -- Element change

	change_value (new_value: INTEGER) is
		do
			function.set_start_y (new_value)
		end

feature -- Basic operations

	valid_value (i: INTEGER): BOOLEAN is
		do
			Result := true
		end

end -- class START_Y_FUNCTION_PARAMETER
