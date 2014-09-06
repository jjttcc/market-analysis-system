note
	description:
		"Changeable slope parameter for MARKET_FUNCTION_LINE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SLOPE_FUNCTION_PARAMETER inherit

	FUNCTION_PARAMETER_WITH_FUNCTION
		redefine
			function
		end

creation {TRADABLE_FUNCTION}

	make

feature -- Access

	function: MARKET_FUNCTION_LINE

	current_value: STRING
		do
			Result := function.slope.out
		end

	name: STRING = "slope"

	value_type_description: STRING = "real value"

	current_value_equals (v: STRING): BOOLEAN
		do
			Result := v.to_real - function.slope < .001
		end

feature -- Element change

	change_value (new_value: STRING)
		do
			function.set_slope (new_value.to_real)
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN
		do
			Result := v /= Void and v.is_real
		end

end -- class SLOPE_FUNCTION_PARAMETER
