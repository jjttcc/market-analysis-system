indexing
	description: "";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ENVELOPE inherit

	LINKED_LIST [MARKET_FUNCTION]
		export {NONE}
			all
		end

creation

	make

feature -- Access

	primary_function: MARKET_FUNCTION is
		do
			Result := first
		end

end -- class ENVELOPE
