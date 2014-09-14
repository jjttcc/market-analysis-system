note
	description: "Numeric commands that operate on a tradable tuple that is %
		%passed in as an argument to the execute feature"
	note1: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class BASIC_NUMERIC_COMMAND inherit

	NUMERIC_COMMAND
		redefine
			root_suppliers
		end

feature -- Access

	root_suppliers: SET [ANY]
		local
			tuples: expanded TRADABLE_TUPLES
		do
			create {LINKED_SET [ANY]} Result.make
			-- This class actually depends on a TRADABLE_TUPLE, but a
			-- TRADABLE_TUPLE is not instantiable and a SIMPLE_TUPLE
			-- conforms to TRADABLE_TUPLE with respect to the
			-- intended semantics of this feature.
			Result.extend (tuples.simple_tuple)
		end

feature -- Status report

	arg_mandatory: BOOLEAN = True

feature -- Basic operations

	execute (arg: TRADABLE_TUPLE)
			-- Sets its value from arg's value
			-- Can be redefined by ancestors.
		do
			value := arg.value
		end

end -- class BASIC_NUMERIC_COMMAND
