indexing
	description: "Facilities needed by descendants - specific list builders"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class LIST_BUILDER

feature {NONE} -- Initialization

	make_factories (factory: TRADABLE_FACTORY) is
			-- Initialize tradable factories from `factory'.  A separate
			-- tradable factory for intraday data is used for efficiency.
		require
			not_void: factory /= Void
		do
			tradable_factory := factory
			intraday_tradable_factory := clone (factory)
			intraday_tradable_factory.set_intraday (true)
			tradable_factory.set_intraday (false)
		ensure
			factory_set: tradable_factory = factory and
				tradable_factory /= Void and not tradable_factory.intraday
			intraday_factory_set: intraday_tradable_factory /= Void and
				intraday_tradable_factory.intraday
		end

feature -- Access

	daily_list: TRADABLE_LIST is deferred end

	intraday_list: TRADABLE_LIST is deferred end

	tradable_factory: TRADABLE_FACTORY

	intraday_tradable_factory: TRADABLE_FACTORY

end -- class LIST_BUILDER
