note
	description: "Tuple factory that produces a STOCK_SPLIT";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class STOCK_SPLIT_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute
		do
			create product
		end

feature -- Access

	product: STOCK_SPLIT

end -- class STOCK_SPLIT_FACTORY
