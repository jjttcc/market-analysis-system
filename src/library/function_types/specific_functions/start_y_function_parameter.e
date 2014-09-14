note
	description:
		"Changeable start_y parameter for TRADABLE_FUNCTION_LINE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class START_Y_FUNCTION_PARAMETER inherit

	FUNCTION_PARAMETER_WITH_FUNCTION
		redefine
			function
		end

creation {TRADABLE_FUNCTION}

	make

feature -- Access

	function: TRADABLE_FUNCTION_LINE

	current_value: STRING
		do
			Result := function.start_y.out
		end

	name: STRING = "y-value for the left-most point"

	value_type_description: STRING = "real value"

	current_value_equals (v: STRING): BOOLEAN
		do
			Result := v.to_real - function.start_y < .001
		end

feature -- Element change

	change_value (new_value: STRING)
		do
			function.set_start_y (new_value.to_real)
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN
		do
			Result := v /= Void and v.is_real
		end

end -- class START_Y_FUNCTION_PARAMETER
