indexing
	description:
		"Windows version of STOCK_SPLIT_FILE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class WINDOWS_STOCK_SPLIT_FILE inherit

	STOCK_SPLIT_FILE
		undefine
			back
		end

	WINDOWS_FILE

creation

	make

end -- WINDOWS_STOCK_SPLIT_FILE
