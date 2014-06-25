note
	description: "A command that responds to an event list request - %
		%a request for a list of all valid market event types for the %
		%specified tradable and period type"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	expected_field_count: INTEGER = 2

	symbol_index: INTEGER = 1

	period_type_index: INTEGER = 2

	send_response_for_tradable (t: TRADABLE [BASIC_MARKET_TUPLE])
		do
			put_ok
			find_and_put_event_list (t)
			put (eom)
		end

	error_context (msg: STRING): STRING
		do
			Result := concatenation (<<error_context_prefix, market_symbol>>)
		end

feature {NONE} -- Basic operations

	find_and_put_event_list (t: TRADABLE [BASIC_MARKET_TUPLE])
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
						message_component_separator, eglist.item.event_type.id,
						message_record_separator>>))
					eglist.forth
				end
				check
					last: eglist.islast
				end
				put (concatenation (<<eglist.item.event_type.name,
						message_component_separator, eglist.item.event_type.id>>))
			end
		end

feature {NONE} -- Implementation - constants

	error_context_prefix: STRING = "retrieving event-type list for "

end -- class EVENT_LIST_REQUEST_CMD
