indexing
	description:
		"A changeable parameter for a market function, such as n for an %
		%n-period moving average."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FUNCTION_PARAMETER inherit

	PART_COMPARABLE

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

	description: STRING is
			-- `name' + " - " + `function.name'
		do
			create Result.make (0)
			Result.append (name)
			Result.append (" - ")
			Result.append (function.name)
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

feature -- Comparison

	infix "<" (other: like Current): BOOLEAN is
		do
			Result := description < other.description
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

invariant

	function_not_void: function /= Void

end -- class FUNCTION_PARAMETER
