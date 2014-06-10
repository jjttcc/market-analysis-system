note
	description: "Numeric commands that produce the low price for the current%
		% trading period (extracted from the argument to the execute routine)"
	note1: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class LOW_PRICE inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute, root_suppliers
		end

feature -- Access

	root_suppliers: SET [ANY]
		local
			tuples: expanded MARKET_TUPLES
		do
			create {LINKED_SET [ANY]} Result.make
			Result.extend (tuples.basic_market_tuple)
		end

feature -- Basic operations

	execute (arg: BASIC_MARKET_TUPLE)
		do
			value := arg.low.value
		ensure then
			value = arg.low.value
		end

end -- class LOW_PRICE
