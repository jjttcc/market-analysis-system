note
	description: "Factory class that manufactures MARKET_EVENT_GENERATORs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class EVENT_GENERATOR_FACTORY inherit

	GENERIC_FACTORY [MARKET_EVENT_GENERATOR]
		redefine
			product
		end

	SIGNAL_TYPES

feature -- Access

	product: MARKET_EVENT_GENERATOR
			-- Result of execution

	event_type: EVENT_TYPE
			-- Event type that will be associated with the new event generator

feature -- Status setting

	set_event_type (arg: EVENT_TYPE)
			-- Set event_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			event_type := arg
		ensure
			event_type_set: event_type = arg and event_type /= Void
		end

	set_signal_type (i: INTEGER)
			-- Set signal_type to `i'.
		require
			type_names.valid_index (i)
		do
			signal_type := i
		ensure
			signal_type_set: signal_type = i
		end

end -- EVENT_GENERATOR_FACTORY
