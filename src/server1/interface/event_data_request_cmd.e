indexing
	description: "A command that responds to a GUI event-data request - a %
		%request for trading signals for a particular tradable"
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

	EVENT_REGISTRANT_WITH_CACHE
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
		local
			constants: expanded APPLICATION_CONSTANTS
		do
			trc_make (dispenser)
			mer_make
		end

feature -- Basic operations

	do_execute (msg: STRING) is
		local
			fields: LIST [STRING]
			d: DATE
		do
			parse_error := false
			target := msg -- set up for tokenization
			fields := tokens (input_field_separator)
			if fields.count < 4 then
				report_error (Error, <<"Fields count wrong for ",
					"trading-signal event request.">>)
				parse_error := true
			end
			if not parse_error then
				symbol := fields @ 1
				d := date_from_string (fields @ 2)
				if d = Void then
					report_error (Error, <<"Invalid start-date specification %
						%for trading signals request: ", fields @ 2>>)
					parse_error := true
				else
					create analysis_start_date.make_by_date (d)
				end
			end
			if not parse_error then
				d := date_from_string (fields @ 3)
				if d = Void then
					report_error (Error, <<"Invalid end-date specification %
						%for trading signals request: ", fields @ 3>>)
					parse_error := true
				else
					create analysis_end_date.make_by_date (d)
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

	analysis_start_date: DATE_TIME
			-- Start date for event processing

	analysis_end_date: DATE_TIME
			-- End date for event processing

	requested_event_types: HASH_TABLE [INTEGER, INTEGER]
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
			i, id: INTEGER
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
					id := f.to_integer
					requested_event_types.put (id, id)
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
			if server_error then
				report_server_error
			elseif
				event_coordinator.event_generators = Void or
				event_coordinator.event_generators.empty
			then
				if
					tradable_pair.left = Void and tradable_pair.right = Void
				then
					if not tradables.symbols.has (symbol) then
						report_error (Invalid_symbol, <<"Symbol '",
							symbol, "' not in database.">>)
					else
						report_error (Error, <<"No data found for symbol ",
							symbol>>)
					end
				else
					report_error (Warning, <<"No requested trading signal %
						%types were valid">>)
				end
			else
				put_ok
				event_coordinator.execute
				put (eom)
			end
		end

	perform_notify is
		local
			dt_util: expanded DATE_TIME_SERVICES
		do
			check
				events_sorted: event_cache.sorted
			end
			if not event_cache.empty then
				from
					event_cache.start
				until
					event_cache.islast
				loop
					put (concatenation (<<
						dt_util.formatted_date (event_cache.item.date,
							'y', 'm', 'd', ""),
						Output_field_separator,
						dt_util.formatted_time (event_cache.item.time,
							'h', 'm', 's', ""),
						Output_field_separator,
						event_cache.item.type_abbreviation,
						Output_record_separator>>))
					event_cache.forth
				end
				put (concatenation (<<
					dt_util.formatted_date (event_cache.item.date,
						'y', 'm', 'd', ""),
					Output_field_separator,
					dt_util.formatted_time (event_cache.item.time,
						'h', 'm', 's', ""),
					Output_field_separator,
					event_cache.item.type_abbreviation>>))
			end
		end

	initialize_event_coordinator is
		local
			left, right: TRADABLE [BASIC_MARKET_TUPLE]
		do
			--Create an event coordinator that only operates on the tradable
			--for `symbol'; initialize the dispatcher, event generators
			--(according to requested_event_types), etc.
			tradable_pair := pair_for_current_symbol
			if event_coordinator = Void then
				create event_dispatcher.make
				event_dispatcher.register (Current)
				create event_coordinator.make (tradable_pair)
				event_coordinator.set_dispatcher (event_dispatcher)
			else
				event_coordinator.make (tradable_pair)
			end
			-- event generators and coordinators currently don't use an
			-- end date, so just set the start date.
			event_coordinator.set_start_date_time (analysis_start_date)
			event_coordinator.set_event_generators (valid_event_generators)
		ensure
			pair_not_void: tradable_pair /= Void
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
					l := market_event_generation_library
					if not t.has_open_interest then
						-- Only market-event generators for stocks are valid.
						l := stock_market_event_generation_library
					end
					l.start
				until
					l.exhausted
				loop
					if
						requested_event_types.has (l.item.event_type.id)
					then
						Result.extend (l.item)
					end
					l.forth
				end
			end
		end

	pair_for_current_symbol: PAIR [TRADABLE [BASIC_MARKET_TUPLE],
			TRADABLE [BASIC_MARKET_TUPLE]] is
		do
			create Result.make (tradables.tradable (symbol,
				period_types @ (period_type_names @ Hourly)),
				tradables.tradable (symbol,
				period_types @ (period_type_names @ Daily)))
		ensure
			not_void: Result /= Void
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<"running market analysis for ",
				symbol>>)
		end

	name: STRING is "Event-data request command"

end -- class EVENT_DATA_REQUEST_CMD
