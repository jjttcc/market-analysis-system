indexing
	description:
		"A changeable parameter for an n-record function"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_FUNCTION_PARAMETER inherit

	FUNCTION_PARAMETER
		redefine
			function
		end

creation {MARKET_FUNCTION}

	make

feature -- Access

	function: N_RECORD_ONE_VARIABLE_FUNCTION

	current_value: INTEGER is
		do
			Result := function.n
		end

	name: STRING is "n-value"

feature -- Element change

	change_value (new_value: INTEGER) is
		do
			function.set_n (new_value)
		end

feature -- Basic operations

	valid_value (i: INTEGER): BOOLEAN is
		do
			Result := i > 0
		end

end -- class N_RECORD_FUNCTION_PARAMETER
