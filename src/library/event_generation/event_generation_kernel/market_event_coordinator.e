indexing
	description:
		"An event coordinator that uses market event generators to generate %
		%market events and passes a queue of the generated events to a %
		%dispatcher"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MARKET_EVENT_COORDINATOR inherit

	EVENT_COORDINATOR
		redefine
			event_generators
		end

feature -- Access

	event_generators: LINEAR [MARKET_EVENT_GENERATOR]

	start_date_time: DATE_TIME
			-- Date and time that the generators are to begin their
			-- analysis - that is, for each market, only the market's
			-- data whose date/time >= `start_date_time' will be processed.

feature -- Status setting

	set_start_date_time (d: DATE_TIME) is
			-- For each member of `event_generators', set the date and time
			-- for which to begin analysis to `d' and update `start_date_time'
			-- to `d'.
		do
			start_date_time := d
			update_generators_date_time
		ensure
			date_time_set: start_date_time = d
		end

	set_event_generators (arg: LINEAR [MARKET_EVENT_GENERATOR]) is
			-- Set event_generators to `arg', call `set_start_date_time'
			-- on each one with `start_date_time', and do any other
			-- initialization needed on each event generator.
		require
			arg_not_void: arg /= Void
			date_not_void: start_date_time /= Void
		do
			event_generators := arg
			update_generators_date_time
		ensure
			event_generators_set: event_generators = arg and
				event_generators /= Void
		end

	set_dispatcher (arg: EVENT_DISPATCHER) is
			-- Set dispatcher to `arg'.
		require
			arg_not_void: arg /= Void
		do
			dispatcher := arg
		ensure
			dispatcher_set: dispatcher = arg and dispatcher /= Void
		end

feature {NONE} -- Implementation

	update_generators_date_time is
			-- Call `set_start_date_time' on each generator with
			-- `start_date_time'.
		do
			if event_generators /= Void then
				from
					event_generators.start
				until
					event_generators.exhausted
				loop
					event_generators.item.set_start_date_time (start_date_time)
					event_generators.forth
				end
			end
		end

end -- class MARKET_EVENT_COORDINATOR
