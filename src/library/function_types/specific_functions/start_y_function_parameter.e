indexing
	description:
		"Changeable start_y parameter for MARKET_FUNCTION_LINE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class START_Y_FUNCTION_PARAMETER inherit

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
			Result := function.start_y.out
		end

	name: STRING is "y-value for the left-most point"

	value_type_description: STRING is "floating point value"

	current_value_equals (v: STRING): BOOLEAN is
		do
			Result := v.to_real - function.start_y < .001
		end

feature -- Element change

	change_value (new_value: STRING) is
		do
			function.set_start_y (new_value.to_real)
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN is
		do
			Result := v /= Void and v.is_real
		end

end -- class START_Y_FUNCTION_PARAMETER
