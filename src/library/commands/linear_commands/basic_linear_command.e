indexing
	description: "Commands that retrieve the value of the current item of %
		%a linear structure of market tuples"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class BASIC_LINEAR_COMMAND inherit

	LINEAR_COMMAND
		redefine
			root_suppliers
		end

creation

	make

feature -- Initialization

	make (tgt: like target) is
		require
			not_void: tgt /= Void
		do
			set (tgt)
		ensure
			target = tgt
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
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			value := target.item.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is False

	target_cursor_not_affected: BOOLEAN is True
			-- True

end -- class BASIC_LINEAR_COMMAND
