note
	description: "Dummy builder of SOCKET_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	SOCKET_LIST_BUILDER

creation

	make

feature -- Initialization

	make (f: TRADABLE_FACTORY)
		do
		end

feature -- Access

	daily_list: TRADABLE_LIST

	intraday_list: TRADABLE_LIST

feature -- Basic operations

	execute
		do
		end

end
