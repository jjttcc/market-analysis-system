indexing
	description:
		"A market event coordinator that generates market events for a %
		%list of tradables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
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
		local
			gs: expanded EXCEPTION_SERVICES
			gu: expanded GENERAL_UTILITIES
			exception_occurred: BOOLEAN
		do
			from
				if not exception_occurred then
					tradables.start
				end
			until
				tradables.exhausted
			loop
				execute_event_generators
				tradables.forth
			end
		rescue
			if not gs.last_exception_status.fatal then
				if not tradables.exhausted then
					-- The exception most likely occurred when the current
					-- tradable (tradables.item) was being processed by
					-- `execute_event_generators', so assume there was a
					-- problem with this tradable and skip to the next one.
					tradables.forth
				end
				exception_occurred := True
				if
					gs.last_exception_status.description /= Void and
					not gs.last_exception_status.description.is_empty
				then
					-- Since the exception is caught here and not allowed
					-- to percolate up further, take responsibility for
					-- reporting of the error description.
					gu.log_errors (<<gs.last_exception_status.description,
						"%N">>)
				end
				retry
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
