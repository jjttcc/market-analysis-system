indexing
	description:
		"A changeable parameter for a market function, such as n for an %
		%n-period moving average."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class FUNCTION_PARAMETER

feature {NONE} -- Initialization

	make (f: MARKET_FUNCTION) is
		require
			not_void: f /= Void
		do
			function := f
		ensure
			set: function = f and function /= Void
		end

feature -- Access

	function: MARKET_FUNCTION
			-- The function that this parameter applies to

	current_value: INTEGER is
			-- Current value of the parameter
		deferred
		end

feature -- Element change

	change_value (new_value: INTEGER) is
			-- Change the value of the parameter to `new_value'.
		require
			value_valid: valid_value (new_value)
		deferred
		ensure
			current_value = new_value
		end

feature -- Basic operations

	valid_value (i: INTEGER): BOOLEAN is
			-- Is `i' a valid value for this parameter?
		deferred
		end

end -- class FUNCTION_PARAMETER
