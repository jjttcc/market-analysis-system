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

	MARKET_FUNCTION_EDITOR
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
		require
			not_void: f /= Void
		deferred
		end

	set_start_date_time (d: DATE_TIME) is
			-- Set the date and time to begin the analysis to `d'.
		require
			not_void: d /= Void
		deferred
		end

feature {MARKET_FUNCTION_EDITOR}

	wipe_out is
			-- Ensure that data is cleared before storage.
		deferred
		end

invariant

	event_type_not_void: event_type /= Void

end -- class MARKET_EVENT_GENERATOR
