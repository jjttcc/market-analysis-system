indexing
	description:
		"Event generators whose events are based on analysis of %
		%MARKET_FUNCTION data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FUNCTION_ANALYZER inherit

	MARKET_EVENT_GENERATOR

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	start_date_time: DATE_TIME
			-- Date/time specifying which trading period to begin the
			-- analysis of market data

	operator: RESULT_COMMAND [BOOLEAN]
			-- Operator used to analyze each tuple - evaluation to true
			-- will result in an event being generated.

	period_type: TIME_PERIOD_TYPE
			-- Period type specifying what type of data from tradable will be
			-- analyzed - daily, weekly, etc. - that is,
			-- `tradable'.`tuple_list' (`period_type'.name).

	tradable: TRADABLE [BASIC_MARKET_TUPLE]
			-- The market whose data is to be analyzed

feature -- Status setting

	set_start_date_time (d: DATE_TIME) is
		do
			start_date_time := d
		ensure then
			start_date_time_set: start_date_time = d and
									start_date_time /= Void
		end

	set_operator (arg: RESULT_COMMAND [BOOLEAN]) is
			-- Set operator to `arg'.
		require
			arg /= Void
		do
			operator := arg
		ensure
			operator_set: operator = arg and operator /= Void
		end

feature -- Basic operations

	generate_event (tuple: MARKET_TUPLE; description: STRING) is
		require
			not_void: tuple /= Void and description /= Void
		local
			s: STRING
			event: ATOMIC_MARKET_EVENT
		do
			check
				tuple.date_time /= Void and tuple.end_date /= Void
			end
			create event.make (event_name, tradable.symbol,
							tuple.date_time, event_type)
			-- For weekly, monthly, etc. data, this will be the date of
			-- the last trading period of which the tuple is composed; for
			-- daily, and intraday data, this will simply be the date
			-- of the tuple's date_time:
			event.set_date (tuple.end_date)
			event.set_time (tuple.date_time.time)
			event.set_description (description)
			product.extend (event)
		end

feature {NONE} -- Hook routines

	set_innermost_function (f: SIMPLE_FUNCTION [MARKET_TUPLE]) is
		require
			not_void: f /= Void
			tradable_set: tradable /= Void
			period_type_set: f.trading_period_type /= Void
			-- tradable has been set to the current tradable.
		deferred
		end

	event_name: STRING is
			-- Name to give to the event when it is created
		deferred
		ensure
			Result /= Void
		end

feature {NONE} -- Implementation

	set_tradable (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Set the tradable whose market data is to be analyzed.
		require
			period_type_valid_for_f: t.valid_period_type (period_type)
		do
			tradable := t
			set_innermost_function (t.tuple_list (period_type.name))
		ensure then
			set: tradable = t
		end

invariant

	period_type_not_void: period_type /= Void

end -- class FUNCTION_ANALYZER
