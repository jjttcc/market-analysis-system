note
	description: "Tuple factory that creates an OPEN_INTEREST_TUPLE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class OI_TUPLE_FACTORY inherit

	VOLUME_TUPLE_FACTORY
		redefine
			product, execute
		end

feature

	execute
		do
			create product.make
		end

feature -- Access

	product: BASIC_OPEN_INTEREST_TUPLE

end -- class OI_TUPLE_FACTORY
