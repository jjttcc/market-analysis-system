indexing
	description:
		"A function parameter with a settable integer value"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INTEGER_FUNCTION_PARAMETER inherit

	FUNCTION_PARAMETER

creation {MARKET_FUNCTION, MARKET_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (v: INTEGER) is
		require
			valid_args: v > 0
		do
			value := v
		ensure
			set: value = v
		end

feature -- Access

	value: INTEGER
			-- The value of the parameter

feature -- Access

	current_value: STRING is
		do
			Result := value.out
		end

	name: STRING is "integer-value"

	description: STRING is
		do
			Result := name
		end

	value_type_description: STRING is "integer value"

	current_value_equals (v: STRING): BOOLEAN is
		do
			Result := v.to_integer = value
		end

feature -- Element change

	change_value (new_value: STRING) is
		do
			value := new_value.to_integer
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN is
		do
			Result := v /= Void and v.is_integer and v.to_integer > 0
		end

end
