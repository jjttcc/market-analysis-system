note
	description: "Facilities needed by descendants - specific list builders"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class LIST_BUILDER

feature {NONE} -- Initialization

	make_factories (factory: TRADABLE_FACTORY)
			-- Initialize tradable factories from `factory'.  A separate
			-- tradable factory for intraday data is used for efficiency.
		require
			not_void: factory /= Void
		do
			tradable_factory := factory
			intraday_tradable_factory := clone (factory)
			intraday_tradable_factory.set_intraday (True)
			tradable_factory.set_intraday (False)
		ensure
			factory_set: tradable_factory = factory and
				tradable_factory /= Void and not tradable_factory.intraday
			intraday_factory_set: intraday_tradable_factory /= Void and
				intraday_tradable_factory.intraday
		end

feature -- Access

	daily_list: TRADABLE_LIST deferred end

	intraday_list: TRADABLE_LIST deferred end

	tradable_factory: TRADABLE_FACTORY

	intraday_tradable_factory: TRADABLE_FACTORY

feature -- Basic operations

	execute
			-- Build and configure `daily_list' and `intraday_list'.
		do
			build_lists
			if intraday_list /= Void then
				intraday_list.set_intraday (True)
			end
		ensure
			at_least_one_list_exists: daily_list /= Void or
				intraday_list /= Void
			intraday_status_set_correctly: (daily_list /= Void implies 
				not daily_list.intraday) and (intraday_list /= Void implies 
				intraday_list.intraday)
		end

feature {NONE} -- Hook routines

	build_lists
			-- Build `daily_list' and `intraday_list'.
		require
			factories_exist: tradable_factory /= Void and
				intraday_tradable_factory /= Void
			descendant_build_lists_precondition
		deferred
		ensure
			at_least_one_list_exists: daily_list /= Void or
				intraday_list /= Void
			intraday_not_set: (daily_list /= Void implies 
				not daily_list.intraday) and (intraday_list /= Void implies 
				not intraday_list.intraday)
		end

	descendant_build_lists_precondition: BOOLEAN
			-- Additional precondition for `build_lists' in descendant
			-- classes
		do
			Result := True -- Redefine if needed.
		end

end -- class LIST_BUILDER
