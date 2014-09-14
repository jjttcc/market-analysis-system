note
	description: "Numeric commands that produce the volume for the current %
		%trading period."
	note1: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class VOLUME inherit

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
			-- This class actually depends on a VOLUME_TUPLE, but a
			-- VOLUME_TUPLE is not instantiable and a BASIC_VOLUME_TUPLE
			-- conforms to VOLUME_TUPLE with respect to the
			-- intended semantics of this feature.
			Result.extend (tuples.basic_volume_tuple)
		end

feature -- Basic operations

	execute (arg: VOLUME_TUPLE)
			-- Can be redefined by ancestors.
		do
			value := arg.volume
		ensure then
			dabs (value - arg.volume) < Epsilon
		end

end -- class VOLUME
