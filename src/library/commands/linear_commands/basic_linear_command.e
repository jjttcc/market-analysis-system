note
	description: "Commands that retrieve the value of the current item of %
		%a linear structure of market tuples"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class BASIC_LINEAR_COMMAND inherit

	LINEAR_COMMAND
		redefine
			root_suppliers
		end

creation

	make

feature -- Initialization

	make (tgt: like target)
		require
			not_void: tgt /= Void
		do
			set (tgt)
		ensure
			target = tgt
		end

feature -- Access

	root_suppliers: SET [ANY]
		local
			tuples: expanded MARKET_TUPLES
		do
			create {LINKED_SET [ANY]} Result.make
			-- This class actually depends on a MARKET_TUPLE, but a
			-- MARKET_TUPLE is not instantiable and a SIMPLE_TUPLE
			-- conforms to MARKET_TUPLE with respect to the
			-- intended semantics of this feature.
			Result.extend (tuples.simple_tuple)
		end

feature -- Basic operations

	execute (arg: ANY)
		do
			value := target.item.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN = False

	target_cursor_not_affected: BOOLEAN = True
			-- True

end -- class BASIC_LINEAR_COMMAND
