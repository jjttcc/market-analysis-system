indexing
	description:
		"A market event coordinator that generates market events for a %
		%list of tradables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_LIST_EVENT_COORDINATOR inherit

	MARKET_EVENT_COORDINATOR
		redefine
			generate_events, initialize
		end

creation

	make

feature -- Initialization

	make (dispenser: TRADABLE_DISPENSER) is
		require
			not_void: dispenser /= Void
		do
			tradables := dispenser
		ensure
			set: tradables = dispenser
		end

feature -- Access

	tradables: TRADABLE_DISPENSER
			-- Tradable entities to be analyzed by `event_generators'

feature {NONE} -- Implementation

	generate_events is
			-- For each element, e, of tradables, execute all elements
			-- of event_generators on e.
		do
			from
				tradables.start
			until
				tradables.exhausted
			loop
				execute_event_generators
				tradables.forth
			end
		end

	initialize (eg: MARKET_EVENT_GENERATOR) is
			-- Set the "tradable" of `eg' from `tradables'.
		do
			eg.set_tradable_from_dispenser (tradables)
		end

invariant

	tradables_not_void: tradables /= Void

end -- class TRADABLE_LIST_EVENT_COORDINATOR
