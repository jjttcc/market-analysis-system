note
	description: "Numeric commands that produce the high price for the current%
		% trading period (extracted from the argument to the execute routine)"
	note1: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class HIGH_PRICE inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute, root_suppliers
		end

feature -- Access

	root_suppliers: SET [ANY]
		local
			tuples: expanded TRADABLE_TUPLES
		do
			create {LINKED_SET [ANY]} Result.make
			Result.extend (tuples.basic_tradable_tuple)
		end

feature -- Basic operations

	execute (arg: BASIC_TRADABLE_TUPLE)
		do
			value := arg.high.value
		ensure then
			value = arg.high.value
		end

end -- class HIGH_PRICE
