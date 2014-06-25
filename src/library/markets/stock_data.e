note
	description: "Miscellaneous information about a stock";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class STOCK_DATA inherit

	TRADABLE_DATA

feature -- Access

	sector: STRING
			-- Name of sector of stock associated with `symbol'
		deferred
		end

end -- class STOCK_DATA
