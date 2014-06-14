note
	description: "Factory class that manufactures MARKET_EVENT_GENERATORs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class EVENT_GENERATOR_FACTORY inherit

	FACTORY [MARKET_EVENT_GENERATOR]
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
