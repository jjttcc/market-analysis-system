indexing
	description:
		"A basic numeric command that produces the volume for the current %
		%trading period."
	note: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
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
		ensure
			not_void: Result /= Void
		end

feature -- Basic operations

	execute (arg: VOLUME_TUPLE) is
			-- Can be redefined by ancestors.
		do
			value := arg.volume
		ensure then
			value = arg.volume
		end

end -- class VOLUME
