indexing
	description:
		"An abstraction for the generation of events based on analysis %
		%of market data"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_EVENT_GENERATOR inherit

	EVENT_GENERATOR
		redefine
			product
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

feature -- Access

	product: CHAIN [MARKET_EVENT]

	event_type: EVENT_TYPE
			-- The type of the generated events

feature -- Status setting

	set_tradable (f: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Set the tradable to be used for analysis to `f'.
		deferred
		end

feature {NONE} -- Implementation

	set_event_type (name: STRING) is
			-- Create an event type with name `name', add it to the global
			-- event table, and set attribute event_type to it.
		do
			create_event_type (name)
			event_type := last_event_type
		ensure
			event_type /= Void
		end

invariant

	event_type_not_void: event_type /= Void

end -- class MARKET_EVENT_GENERATOR
