indexing
	description: "Dummy builder of SOCKET_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	SOCKET_LIST_BUILDER

creation

	make

feature -- Initialization

	make (f: TRADABLE_FACTORY) is
		do
		end

feature -- Access

	daily_list: TRADABLE_LIST

	intraday_list: TRADABLE_LIST

feature -- Basic operations

	execute is
		do
		end

end
