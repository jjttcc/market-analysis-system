indexing
	description: "Numeric commands that produce the closing price for the %
		%current trading period (extracted from the argument to the %
		%execute routine)"
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CLOSING_PRICE inherit

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
			Result.extend (tuples.basic_market_tuple)
		end

feature -- Basic operations

	execute (arg: BASIC_MARKET_TUPLE) is
		do
			value := arg.close.value
		ensure then
			value = arg.close.value
		end

end -- class CLOSING_PRICE
