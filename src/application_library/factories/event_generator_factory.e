indexing
	description: "Factory class that manufactures MARKET_EVENT_GENERATORs"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class EVENT_GENERATOR_FACTORY inherit

	FACTORY
		redefine
			product
		end

feature -- Access

	product: MARKET_EVENT_GENERATOR
			-- Result of execution

	event_type: EVENT_TYPE
			-- Event type that will be associated with the new event generator

feature -- Status setting

	set_event_type (arg: EVENT_TYPE) is
			-- Set event_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			event_type := arg
		ensure
			event_type_set: event_type = arg and event_type /= Void
		end

end -- EVENT_GENERATOR_FACTORY
