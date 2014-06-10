note
	description:
		"A changeable parameter for an n-record function"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class N_RECORD_FUNCTION_PARAMETER inherit

	FUNCTION_PARAMETER_WITH_FUNCTION
		redefine
			function
		end

creation {MARKET_FUNCTION}

	make

feature -- Access

	function: N_RECORD_ONE_VARIABLE_FUNCTION

	current_value: STRING
		do
			Result := function.n.out
		end

	name: STRING = "n-value"

	value_type_description: STRING = "integer value"

	current_value_equals (v: STRING): BOOLEAN
		do
			Result := v.to_integer = function.n
		end

feature -- Element change

	change_value (new_value: STRING)
		do
			function.set_n (new_value.to_integer)
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN
		do
			Result := v /= Void and v.is_integer and v.to_integer > 0
		end

end -- class N_RECORD_FUNCTION_PARAMETER
