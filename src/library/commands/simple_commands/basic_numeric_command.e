indexing
	description: "Numeric commands that operate on a market tuple that is %
		%passed in as an argument to the execute feature"
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class BASIC_NUMERIC_COMMAND inherit

	NUMERIC_COMMAND
		redefine
			root_suppliers
		end

feature -- Access

	root_suppliers: SET [ANY] is
		local
			tuples: expanded MARKET_TUPLES
		do
			create {LINKED_SET [ANY]} Result.make
			-- This class actually depends on a MARKET_TUPLE, but a
			-- MARKET_TUPLE is not instantiable and a SIMPLE_TUPLE
			-- conforms to MARKET_TUPLE with respect to the
			-- intended semantics of this feature.
			Result.extend (tuples.simple_tuple)
		ensure
			not_void: Result /= Void
		end

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (arg: MARKET_TUPLE) is
			-- Sets its value from arg's value
			-- Can be redefined by ancestors.
		do
			value := arg.value
		end

end -- class BASIC_NUMERIC_COMMAND
