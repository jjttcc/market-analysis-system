indexing
	description: "Builder of SOCKET_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class SOCKET_LIST_BUILDER inherit

	LIST_BUILDER
		rename
			make_factories as make
		end

creation

	make

feature -- Access

	daily_list: SOCKET_TRADABLE_LIST

	intraday_list: SOCKET_TRADABLE_LIST

feature -- Basic operations

	execute is
		require
			input_items_set: tradable_factory /= Void
		do
			daily_list := new_tradable_list (tradable_factory)
			intraday_list := new_tradable_list (intraday_tradable_factory)
		end


	new_tradable_list (factory: TRADABLE_FACTORY):
			SOCKET_TRADABLE_LIST is
		local
			l: LINKED_LIST [STRING]
		do
			create l.make
			l.fill (<<"aapl", "ibm", "rhat", "novl", "f">>)
			create Result.make (l, factory)
		end

end
