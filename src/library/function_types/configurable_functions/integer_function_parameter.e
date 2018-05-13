note
	description:
		"A function parameter with a settable integer value"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class INTEGER_FUNCTION_PARAMETER inherit

	FUNCTION_PARAMETER
		redefine
			set_name
		end

creation {TRADABLE_FUNCTION, TRADABLE_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (v: INTEGER; o: TREE_NODE)
		require
			valid_args: v > 0
		do
			value := v
			name := "integer-value"
			owner := o
		ensure
			set: value = v and owner = o
		end

feature -- Access

	value: INTEGER
			-- The value of the parameter

	owner: TREE_NODE

feature -- Access

	current_value: STRING
		do
			Result := value.out
		end

	name: STRING

	description: STRING
		do
			Result := name
		end

	value_type_description: STRING = "integer value"

	current_value_equals (v: STRING): BOOLEAN
		do
			Result := v.to_integer = value
		end

feature -- Element change

	change_value (new_value: STRING)
		do
			value := new_value.to_integer
		end

	set_name (n: STRING)
		do
			name := n.twin
		ensure then
			name_set: equal(name, n)
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN
		do
			Result := v /= Void and v.is_integer and v.to_integer > 0
		end

end
