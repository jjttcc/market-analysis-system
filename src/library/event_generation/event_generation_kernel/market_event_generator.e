indexing
	description:
		"An abstraction for the generation of events based on analysis %
		%of market data"
	constraints: "`tradables' must be set before `execute' is called."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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

	indicators: LIST [MARKET_FUNCTION] is
			-- Technical indicators used for analysis
		deferred
		end

	tradables: TRADABLE_DISPENSER

feature -- Status setting

	set_tradables (arg: TRADABLE_DISPENSER) is
			-- Set tradables to `arg'.
		require
			arg_not_void: arg /= Void
		do
			tradables := arg
		ensure
			tradables_set: tradables = arg and tradables /= Void
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
