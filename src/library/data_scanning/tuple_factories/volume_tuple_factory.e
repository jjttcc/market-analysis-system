indexing
	description: "Tuple factory that creates a BASIC_VOLUME_TUPLE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class VOLUME_TUPLE_FACTORY inherit

	BASIC_TUPLE_FACTORY
		redefine
			product, execute
		end

feature

	execute is
		do
			create product.make
		end

feature -- Access

	product: BASIC_VOLUME_TUPLE

end -- class VOLUME_TUPLE_FACTORY
