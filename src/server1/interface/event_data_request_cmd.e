indexing
	description: "A command that responds to a GUI event-data request - a %
		%request for trading signals for a particular tradable and period type"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EVENT_DATA_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND
		rename
			make as trc_make, event_types as global_event_types
		redefine
			error_context
		end

	GUI_PROTOCOL_UTILITIES
		export
			{NONE} all
		end

	STRING_UTILITIES
		rename
			make as su_make_unused
		export
			{NONE} all
		end

	MARKET_EVENT_REGISTRANT
		rename
			make as mer_make
		export
			{NONE} all
		redefine
			event_cache
		end

creation

	make

feature {NONE} -- Initialization

	make (dispenser: TRADABLE_DISPENSER) is
		do
			trc_make (dispenser)
			mer_make
		end

feature -- Basic operations

	do_execute (msg: STRING) is
		local
			fields: LIST [STRING]
		do
			target := msg -- set up for tokenization
			fields := tokens (input_field_separator)
			if fields.count < 4 then
				report_error (Error, <<"Fields count wrong for ",
					"trading-signal event request.">>)
				parse_error := true
			end
			if not parse_error then
				symbol := fields @ 1
				analysis_start_date := date_from_string (fields @ 2)
				if analysis_start_date = Void then
					report_error (Error, <<"Invalid start-date specification %
						%for trading signals request: ", fields @ 2>>)
					parse_error := true
				end
			end
			if not parse_error then
				analysis_end_date := date_from_string (fields @ 3)
				if analysis_end_date = Void then
					report_error (Error, <<"Invalid end-date specification %
						%for trading signals request: ", fields @ 3>>)
					parse_error := true
				end
			end
			if not parse_error then
				create_event_types (fields)
			end
			if not parse_error then
				send_response
			end
		end

feature {NONE} -- Implementation

	symbol: STRING
			-- Symbol for the tradable to be processed

	analysis_start_date: DATE
			-- Start date for event processing

	analysis_end_date: DATE
			-- End date for event processing

	requested_event_types: ARRAYED_LIST [INTEGER]
			-- Event types to be processed

	parse_error: BOOLEAN
			-- Did a parse error occur?

	event_coordinator: TRADABLE_EVENT_COORDINATOR
			-- Coordinator for events to be processed

	tradable_pair: PAIR [TRADABLE [BASIC_MARKET_TUPLE],
		TRADABLE [BASIC_MARKET_TUPLE]]
			-- Intraday and non-intraday tradables for `symbol'

	event_dispatcher: EVENT_DISPATCHER

	event_cache: PART_SORTED_TWO_WAY_LIST [MARKET_EVENT]

feature {NONE}

	create_event_types (fields: LIST [STRING]) is
			-- Create `requested_event_types' from fields[4 .. fields.count].
		local
			i: INTEGER
			f: STRING
		do
			create requested_event_types.make (fields.count - 3)
			from i := 4 until i > fields.count or parse_error loop
				f := fields @ i
				if not f.is_integer then
					report_error (Error, <<"Invalid event ID ",
						"for trading signals request - non-integer: ", f>>)
					parse_error := true
				else
					requested_event_types.extend (f.to_integer)
				end
				i := i + 1
			end
		end

	send_response is
			-- Run market analysis on for `symbol' for all event types
			-- specified in `requested_event_types' between
			-- `analysis_start_date' and `analysis_end_date'.
		require
			settings_not_void: analysis_start_date /= Void and
				analysis_end_date /= Void and symbol /= Void and
				requested_event_types /= Void
		do
			initialize_event_coordinator
			event_coordinator.execute
-- !!!Anything else?
		end

	perform_notify is
		do
			check
				events_sorted: event_cache.sorted
			end
--!!!Here's where the event list is sorted and sent back to
--!!!the GUI client.
		end

	initialize_event_coordinator is
		local
			left, right: TRADABLE [BASIC_MARKET_TUPLE]
		do
--!!!Stub
			--Create an event coordinator that only operates on the tradable
			--for `symbol'; initialize the dispatcher, event generators
			--(according to requested_event_types), etc.
			tradable_pair := pair_for_current_symbol
			if event_coordinator = Void then
				event_dispatcher.make
				event_dispatcher.register (Current)
				create event_coordinator.make (tradable_pair)
				event_coordinator.set_dispatcher (event_dispatcher)
				event_coordinator.set_event_generators (valid_event_generators)
			else
				event_coordinator.make (tradable_pair)
			end
		end

	valid_event_generators: LINKED_LIST [MARKET_EVENT_GENERATOR] is
			-- Event generators specified in `requested_event_types' that
			-- are valid for `tradable_pair'
		require
			pair_set: tradable_pair /= Void
		local
			l: LIST [MARKET_EVENT_GENERATOR]
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
			create Result.make
			t := tradable_pair.right
			if t = Void then
				t := tradable_pair.left
			end
			if t /= Void then
				from
					if t.has_open_interest then
						-- All market-event generators are valid.
						l := market_event_generation_library
					else
						-- Only market-event generators for stocks are valid.
						l := stock_market_event_generation_library
					end
					l.start
				until
					l.exhausted
				loop
					from
						requested_event_types.start
					until
						requested_event_types.exhausted
					loop
						requested_event_types.forth
						if
							l.item.event_type.id = requested_event_types.item
						then
							Result.extend (l.item)
						end
					end
					l.forth
				end
			end
		end

	pair_for_current_symbol: PAIR [TRADABLE [BASIC_MARKET_TUPLE],
			TRADABLE [BASIC_MARKET_TUPLE]] is
		do
			Result.make (tradables.tradable (symbol,
				period_types @ (period_type_names @ Hourly)),
				tradables.tradable (symbol,
				period_types @ (period_type_names @ Daily)))
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<"running market analysis for ",
				symbol>>)
		end

	name: STRING is "Event-data request command"

end -- class EVENT_DATA_REQUEST_CMD
