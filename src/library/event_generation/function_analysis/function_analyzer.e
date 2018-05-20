note
	description:
		"Event generators whose events are based on analysis of %
		%TRADABLE_FUNCTION data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class FUNCTION_ANALYZER inherit

	TRADABLE_EVENT_GENERATOR

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	start_date_time: DATE_TIME
			-- Date/time specifying which trading period to begin the
			-- analysis of tradable data

	end_date_time: DATE_TIME
			-- Date/time specifying which trading period to end the
			-- analysis of tradable data

	operator: RESULT_COMMAND [BOOLEAN]
			-- Operator used to analyze each tuple - evaluation to True
			-- will result in an event being generated.

	period_type: TIME_PERIOD_TYPE
			-- Period type specifying what type of data from current_tradable
			-- will be analyzed - daily, weekly, etc. - that is,
			-- `current_tradable'.`tuple_list' (`period_type'.name).

	current_tradable: TRADABLE [BASIC_TRADABLE_TUPLE]
			-- The tradable whose data is to be analyzed

	immediate_operators: LIST [COMMAND]
		do
			create {LINKED_LIST [COMMAND]} Result.make
			Result.extend (operator)
		end

feature -- Status report

	valid_period_type (t: TIME_PERIOD_TYPE): BOOLEAN
		do
			Result := t.intraday = period_type.intraday
		end

feature -- Status setting

	set_start_date_time (d: DATE_TIME)
		do
			start_date_time := d
		ensure then
			start_date_time_set: start_date_time = d and
									start_date_time /= Void
		end

	set_end_date_time (d: DATE_TIME)
		do
			end_date_time := d
		ensure then
			end_date_time_set: end_date_time = d and
									end_date_time /= Void
		end

	set_operator (arg: RESULT_COMMAND [BOOLEAN])
			-- Set operator to `arg'.
		require
			arg /= Void
		do
			operator := arg
		ensure
			operator_set: operator = arg and operator /= Void
		end

	set_tradable_from_dispenser (d: TRADABLE_DISPENSER)
			-- Set `current_tradable' from the current item in `d'
			-- for `period_type'.
		local
			s: STRING
			t: TRADABLE [BASIC_TRADABLE_TUPLE]
		do
			current_tradable := Void
			--@@@Check if 'update' (True) should be False:
			t := d.item (period_type, True)
			if t = Void then
				if d.error_occurred then
					s := concatenation (<<
						"Error occurred processing event ", event_type.name,
						"with period type ", period_type.name,
						":%N", d.last_error, ".%N">>)
				else
					s := concatenation (<<
						"Error occurred processing event ", event_type.name,
						"with period type ", period_type.name,
						":%NFailed to process item # ", d.index, ".%N">>)
				end
				log_error (s)
			else
				check
					period_type_valid_for_f: t.valid_period_type (period_type)
				end
				do_set_tradable (t)
			end
		end

	set_tradable_from_pair (p: PAIR [TRADABLE [BASIC_TRADABLE_TUPLE],
			TRADABLE [BASIC_TRADABLE_TUPLE]])
		local
			t: TRADABLE [BASIC_TRADABLE_TUPLE]
		do
			current_tradable := Void
			if p.left /= Void and p.left.valid_period_type (period_type) then
				do_set_tradable (p.left)
			elseif
				p.right /= Void and p.right.valid_period_type (period_type)
			then
				do_set_tradable (p.right)
			else
				log_error (concatenation (<<
					"Error occurred processing event ", event_type.name,
					" for symbol ", t.symbol, " with period type ",
					period_type.name, ":%NInvalid event period type.%N">>))
			end
		end

feature -- Basic operations

	generate_event (tuple: TRADABLE_TUPLE; description: STRING)
		require
			not_void: tuple /= Void and description /= Void
		local
			event: ATOMIC_TRADABLE_EVENT
		do
			check
				tuple.date_time /= Void and tuple.end_date /= Void
			end
			create event.make (event_name, current_tradable.symbol,
				tuple.date_time, event_type, signal_type)
			-- For weekly, monthly, etc. data, this will be the date of
			-- the last trading period of which the tuple is composed; for
			-- daily, and intraday data, this will simply be the date
			-- of the tuple's date_time:
			event.set_date (tuple.end_date)
			event.set_time (tuple.date_time.time)
			event.set_description (description)
			product.extend (event)
		end

feature {NONE} -- Implementation

	do_set_tradable (t: TRADABLE [BASIC_TRADABLE_TUPLE])
		require
			valid_period_type: t /= Void and t.valid_period_type (period_type)
		do
			current_tradable := t
			set_innermost_function (t.tuple_list (period_type.name))
		ensure then
			set: current_tradable = t
		end

feature {NONE} -- Hook routines

	set_innermost_function (f: SIMPLE_FUNCTION [TRADABLE_TUPLE])
		require
			not_void: f /= Void
			tradable_set: current_tradable /= Void
			period_type_set: f.trading_period_type /= Void
			-- current_tradable has been set to the current tradable.
		deferred
		end

	event_name: STRING
			-- Name to give to the event when it is created
		deferred
		ensure
			Result /= Void
		end

invariant

	period_type_not_void: period_type /= Void

end -- class FUNCTION_ANALYZER
