note
	description:
		"A market function parameter that refers back to its owning function"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FUNCTION_PARAMETER_WITH_FUNCTION inherit

	FUNCTION_PARAMETER
		redefine
			description, is_equal
		end

feature {NONE} -- Initialization

	make (f: MARKET_FUNCTION)
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

	description: STRING
		do
			if function.name /= Void then
				Result := name + " - " + function.name
			else
				Result := name
			end
		end

feature -- Comparison

	is_equal (other: FUNCTION_PARAMETER): BOOLEAN
		local
			fpwf: like Current
		do
			fpwf ?= other
			if fpwf /= Void then
				Result := description.is_equal (fpwf.description) and
					function = fpwf.function
			end
		end

invariant

	function_not_void: function /= Void

end
