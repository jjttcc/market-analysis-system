indexing
	description:
		"A changeable parameter for a market function, such as n for an %
		%n-period moving average."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FUNCTION_PARAMETER inherit

	PART_COMPARABLE
		redefine
			is_equal
		end

feature {NONE} -- Initialization

feature -- Access

	current_value: STRING is
			-- Current value of the parameter
		deferred
		end

	name: STRING is
			-- The name of the parameter - unique among parameters belonging
			-- to a particular MARKET_FUNCTION
		deferred
		end

	description: STRING is
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

feature -- Comparison

	infix "<" (other: FUNCTION_PARAMETER): BOOLEAN is
		do
			Result := description < other.description
		end

	is_equal (other: FUNCTION_PARAMETER): BOOLEAN is
		do
			-- Redefined here to allow descendants to compare with other
			-- FUNCTION_PARAMETERs instead of "like Current".
			Result := Precursor (other)
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
