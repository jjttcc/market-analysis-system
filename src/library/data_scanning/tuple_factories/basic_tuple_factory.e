note
	description: "Tuple factory that produces a BASIC_TRADABLE_TUPLE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class BASIC_TUPLE_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute
		do
			create product.make
		end

feature -- Access

	product: BASIC_TRADABLE_TUPLE

end -- class BASIC_TUPLE_FACTORY
