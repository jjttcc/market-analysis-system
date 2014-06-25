note
	description: "Tuple factory that creates an OPEN_INTEREST_TUPLE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
