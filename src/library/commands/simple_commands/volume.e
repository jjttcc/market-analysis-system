indexing
	description: "Numeric commands that produce the volume for the current %
		%trading period."
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class VOLUME inherit

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
			-- This class actually depends on a VOLUME_TUPLE, but a
			-- VOLUME_TUPLE is not instantiable and a BASIC_VOLUME_TUPLE
			-- conforms to VOLUME_TUPLE with respect to the
			-- intended semantics of this feature.
			Result.extend (tuples.basic_volume_tuple)
		end

feature -- Basic operations

	execute (arg: VOLUME_TUPLE) is
			-- Can be redefined by ancestors.
		do
			value := arg.volume
		ensure then
			rabs (value - arg.volume) < Epsilon
		end

end -- class VOLUME
