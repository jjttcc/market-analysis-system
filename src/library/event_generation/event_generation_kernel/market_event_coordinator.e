indexing
	description:
		"An event coordinator that uses market event generators to generate %
		%market events and passes a queue of the generated events to a %
		%dispatcher"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_EVENT_COORDINATOR inherit

	EVENT_COORDINATOR
		redefine
			event_generators, initialize
		end

creation

	make

feature -- Initialization

	make (egs: LINEAR [MARKET_EVENT_GENERATOR];
			markets: LINEAR [TRADABLE [BASIC_MARKET_TUPLE]];
			disp: EVENT_DISPATCHER) is
		require
			not_void: egs /= Void and markets /= Void and disp /= Void
		do
			event_generators := egs
			market_list := markets
			dispatcher := disp
		ensure
			set: event_generators = egs and market_list = markets and
					dispatcher = disp
		end

feature -- Access

	event_generators: LINEAR [MARKET_EVENT_GENERATOR]

	market_list: LINEAR [TRADABLE [BASIC_MARKET_TUPLE]]
			-- Markets to be analyzed by `event_generators'

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
			-- Set event_generators to `arg' and call `set_start_date_time'
			-- on each one with `start_date_time'.
		require
			arg_not_void: arg /= Void
		do
			event_generators := arg
			update_generators_date_time
		ensure
			event_generators_set: event_generators = arg and
				event_generators /= Void
		end

feature {NONE} -- Implementation

	initialize (g: MARKET_EVENT_GENERATOR) is
		do
			g.set_tradable (current_tradable)
		end

	generate_events is
			-- For each element, m, of market_list, execute all elements
			-- of event_generators on m.
		do
			from
				market_list.start
			until
				market_list.exhausted
			loop
				current_tradable := market_list.item
				if
					current_tradable /= Void and not
					current_tradable.data.empty
				then
					execute_event_generators
				end
				market_list.forth
			end
		end

	update_generators_date_time is
			-- Call `set_start_date_time' on each generator with
			-- `start_date_time'.
		do
			from
				event_generators.start
			until
				event_generators.exhausted
			loop
				event_generators.item.set_start_date_time (start_date_time)
				event_generators.forth
			end
		end

	current_tradable: TRADABLE [BASIC_MARKET_TUPLE]

invariant

	ml_not_void: market_list /= Void

end -- class MARKET_EVENT_COORDINATOR
