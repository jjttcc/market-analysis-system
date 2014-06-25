indexing
	description: "";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class FUNCTION_GROUP inherit

	LINKED_LIST [MARKET_FUNCTION]
		export {NONE}
			all
		end

creation

	make

end -- class FUNCTION_GROUP
