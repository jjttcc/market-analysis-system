note
	description: "Tuple factory that produces a TRADE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADE_FACTORY inherit

	FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute
		do
			create product.make
		end

feature -- Access

	product: TRADE

end -- class TRADE_FACTORY
