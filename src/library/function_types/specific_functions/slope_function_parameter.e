indexing
	description:
		"Changeable slope parameter for MARKET_FUNCTION_LINE"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
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

	current_value: STRING is
		do
			Result := function.slope.out
		end

	name: STRING is "slope"

	value_type_description: STRING is "floating point value"

	current_value_equals (v: STRING): BOOLEAN is
		do
			Result := v.to_real - function.slope < .001
		end

feature -- Element change

	change_value (new_value: STRING) is
		do
			function.set_slope (new_value.to_real)
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN is
		do
			Result := v /= Void and v.is_real
		end

end -- class SLOPE_FUNCTION_PARAMETER
