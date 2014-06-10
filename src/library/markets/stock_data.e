note
	description: "Miscellaneous information about a stock";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class STOCK_DATA inherit

	TRADABLE_DATA

feature -- Access

	sector: STRING
			-- Name of sector of stock associated with `symbol'
		deferred
		end

end -- class STOCK_DATA
