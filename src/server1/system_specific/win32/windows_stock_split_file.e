note
	description:
		"Windows version of STOCK_SPLIT_FILE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class WINDOWS_STOCK_SPLIT_FILE inherit

	STOCK_SPLIT_FILE
		undefine
			back
		end

	WINDOWS_FILE

creation

	make

end -- WINDOWS_STOCK_SPLIT_FILE
