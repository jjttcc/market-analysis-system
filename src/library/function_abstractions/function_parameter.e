indexing
	description:
		"A changeable parameter for a market function, such as n for an %
		%n-period moving average."
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
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

	current_value: STRING is
			-- Current value of the parameter
		deferred
		end

	name: STRING is
			-- The name of the parameter
		deferred
		end

	value_type_description: STRING is
			-- Description of the type needed by `current_value'.
		deferred
		end

	current_value_equals (v: STRING): BOOLEAN is
			-- Does `v' match the current value according to the
			-- internal type of the value?
		deferred
		end

feature -- Element change

	change_value (new_value: STRING) is
			-- Change the value of the parameter to `new_value'.
		require
			value_valid: valid_value (new_value)
		deferred
		ensure
			current_value_equals (new_value)
		end

feature -- Basic operations

	valid_value (i: STRING): BOOLEAN is
			-- Is `i' a valid value for this parameter?
		deferred
		end

end -- class FUNCTION_PARAMETER
