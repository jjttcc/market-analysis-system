indexing
	description:
		"Event generators whose events are based on analysis of %
		%MARKET_FUNCTION data"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class FUNCTION_ANALYZER inherit

	MARKET_EVENT_GENERATOR

feature -- Access

	start_date_time: DATE_TIME
			-- Date/time specifying which trading period to begin the
			-- analysis of market data

	operator: RESULT_COMMAND [BOOLEAN]
			-- Operator used to analyze each tuple - evaluation to true
			-- will result in an event being generated.

	period_type: TIME_PERIOD_TYPE
			-- The period type to be analyzed - daily, weekly, etc.

	tradable: TRADABLE [BASIC_MARKET_TUPLE]

feature -- Status setting

	set_tradable (f: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Set the tradable whose market data is to be analyzed.
		do
			check
				-- Unfortunately, this cannot be a precondition.
				f_has_period_type: f.tuple_list_names.has (period_type.name)
			end
			set_innermost_function (f.tuple_list (period_type.name))
			tradable := f
		ensure then
			set: tradable = f
		end

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

	generate_event (time_stamp: DATE_TIME; name, description: STRING) is
		require
			not_void: time_stamp /= Void and name /= Void and
						description /= Void
		local
			s: STRING
			event: ATOMIC_MARKET_EVENT
		do
			--!!!Do we need another date/time field in the event, so
			--!!!that the event generation time, as well as the time
			--!!!of the tuple that caused the event, are stored?
			--!!!Or maybe we need a descendant of TYPED_EVENT that also
			--!!!stores the tuple??
			!!event.make (name, tradable.symbol, time_stamp, event_type)
			s := concatenation (<<"Event for market ", tradable.name, ": ">>)
			description.prepend (s)
			event.set_description (description)
			product.extend (event)
		end

feature {NONE} -- Hook routines

	set_innermost_function (f: SIMPLE_FUNCTION [MARKET_TUPLE]) is
		deferred
		end

invariant

	period_type_not_void: period_type /= Void

end -- class FUNCTION_ANALYZER
