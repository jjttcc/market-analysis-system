indexing
	description:
		"A basic numeric command that produces the open interest for the %
		%current trading period."
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class OPEN_INTEREST inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute, root_suppliers
		end

feature -- Access

	root_suppliers: SET [ANY] is
		local
			tuples: expanded MARKET_TUPLES
		do
			create {LINKED_SET [ANY]} Result.make
			-- This class actually depends on a OPEN_INTEREST_TUPLE, but a
			-- OPEN_INTEREST_TUPLE is not instantiable and a
			-- BASIC_OPEN_INTEREST_TUPLE conforms to OPEN_INTEREST_TUPLE
			-- with respect to the intended semantics of this feature.
			Result.extend (tuples.basic_open_interest_tuple)
		ensure
			not_void: Result /= Void
		end

feature -- Basic operations

	execute (arg: OPEN_INTEREST_TUPLE) is
			-- Can be redefined by ancestors.
		do
			value := arg.open_interest
		ensure then
			value = arg.open_interest
		end

end -- class OPEN_INTEREST
