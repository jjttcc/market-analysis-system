indexing
	description: "A command that responds to an event list request - %
		%a request for a list of all valid market event types for the %
		%specified tradable and period type"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EVENT_LIST_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		redefine
			error_context, send_response_for_tradable
		end

	GLOBAL_APPLICATION
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Hook routine implementations

	expected_field_count: INTEGER is 2

	symbol_index: INTEGER is 1

	period_type_index: INTEGER is 2

	send_response_for_tradable (t: TRADABLE [BASIC_MARKET_TUPLE]) is
		do
			put_ok
			find_and_put_event_list (t)
			put (eom)
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<error_context_prefix, market_symbol>>)
		end

feature {NONE} -- Basic operations

	old_remove_do_execute (msg: STRING) is
		local
			fields: LIST [STRING]
		do
			target := msg
			fields := tokens (Message_field_separator)
			if fields.count /= 2 then
				report_error (Error, <<"Wrong number of fields.">>)
			else
				parse_symbol_and_period_type (1, 2, fields)
				if not parse_error then
					old_remove_send_response
				end
			end
		end

	old_remove_send_response is
			-- Obtain the list of all valid market events for `market_symbol'
			-- and `trading_period_type' and send it to the client.
		local
			tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			tradable := cached_tradable (market_symbol, trading_period_type)
			if tradable = Void then
				if server_error then
					report_server_error
				elseif not tradables.symbols.has (market_symbol) then
					report_error (Invalid_symbol, <<"Symbol not in database.">>)
				else
					report_error (Invalid_period_type,
						<<"Invalid period type: ", trading_period_type.name>>)
				end
			else
				put_ok
				find_and_put_event_list (tradable)
				put (eom)
			end
		end

	find_and_put_event_list (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Find list of all event types valid for `t' and
			-- `trading_period_type' and "put" them.
		local
			l, eglist: LIST [MARKET_EVENT_GENERATOR]
			meg: MARKET_EVENT_GENERATOR
		do
			from
				l := market_event_generation_library
				if not t.has_open_interest then
					-- Only market-event generators for stocks are valid.
					l := stock_market_event_generation_library
				end
				create {ARRAYED_LIST [MARKET_EVENT_GENERATOR]} eglist.make (
					l.count)
				l.start
			until
				l.exhausted
			loop
				meg := l.item
				if meg.valid_period_type (trading_period_type) then
					eglist.extend (l.item)
				end
				l.forth
			end
			if not eglist.is_empty then
				from
					eglist.start
				until
					eglist.islast
				loop
					put (concatenation (<<eglist.item.event_type.name,
						Message_field_separator, eglist.item.event_type.id,
						Message_record_separator>>))
					eglist.forth
				end
				check
					last: eglist.islast
				end
				put (concatenation (<<eglist.item.event_type.name,
						Message_field_separator, eglist.item.event_type.id>>))
			end
		end

feature {NONE} -- Implementation - constants

	error_context_prefix: STRING is "retrieving event-type list for "

end -- class EVENT_LIST_REQUEST_CMD
