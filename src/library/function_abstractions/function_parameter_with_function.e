indexing
	description:
		"A market function parameter that refers back to its owning function"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FUNCTION_PARAMETER_WITH_FUNCTION inherit

	FUNCTION_PARAMETER
		redefine
			description
		end

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

	description: STRING is
			-- `name' + " - " + `function.name'
		do
			Result := name + " - " + function.name
		end

invariant

	function_not_void: function /= Void

end
