indexing
	description:
		"A function analyzer that combines the events of a pair of function %
		%analyzers.  Provides a means of implementing 'and' conditions %
		%between different types of events."
	example:
		"Contains 2 function analyzers:  a 1-var function analyzer for %
		%generating signals from stochastic, and a compound function %
		%analyzer that contains a 2-var function analyzer for generating %
		%signals from MACD signal/difference crossover and a 2-var function %
		%analyzer for generating signals from price vs. moving average. %
		%!!!Move this example somewhere else."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMPOUND_EVENT_GENERATOR inherit

	MARKET_EVENT_GENERATOR

creation

	make

feature {NONE} -- Initialization

	make (la, ra: MARKET_EVENT_GENERATOR; event_type_name: STRING) is
		require
			not_void: la /= Void and ra /= Void
		do
			left_analyzer := la
			right_analyzer := ra
			!!before_extension.make (0, 0, 0, 0, 0, 0)
			!!after_extension.make (0, 0, 0, 0, 0, 0)
			set_event_type (event_type_name)
		ensure
			analyzers_set: left_analyzer = la and right_analyzer = ra
			extensions_set_to_0:
				before_extension.is_equal (before_extension.zero) and
				after_extension.is_equal (before_extension.zero)
			left_target_type_void: left_target_type = Void
		end

feature -- Access

	left_analyzer, right_analyzer: MARKET_EVENT_GENERATOR
			-- Contained function analyzers

	before_extension, after_extension: DATE_TIME_DURATION
			-- Before and after time extensions to the current event - used
			-- to produce a time interval from the time stamp of each event
			-- produced by right_analyzer that will produce a match with an
			-- event produced by left_analyzer if this time interval
			-- intersects with the left_analyzer event's time stamp.

	left_target_type: EVENT_TYPE
			-- Event type specifying which component of left_analyzer's
			-- events to use to obtain the time stamp for date/time
			-- comparison.  If left_target_type is Void, the event's time
			-- stamp will be used, rather than that of one of its components.

feature -- Status setting

	set_tradable (f: TRADABLE [BASIC_MARKET_TUPLE]) is
		do
			left_analyzer.set_tradable (f)
			right_analyzer.set_tradable (f)
		end

	set_before_extension (arg: DATE_TIME_DURATION) is
			-- Set before_extension to -`arg'.
		require
			arg_not_void: arg /= Void
		do
			before_extension := -arg
		ensure
			not_void: before_extension /= Void
			;(before_extension + arg).is_equal (arg.zero)
			--before_extension_opposite: before_extension = -arg
		end

	set_after_extension (arg: DATE_TIME_DURATION) is
			-- Set after_extension to `arg'.
		require
			arg_not_void: arg /= Void
		do
			after_extension := arg
		ensure
			after_extension_set: after_extension = arg and
									after_extension /= Void
		end

	set_left_target_type (arg: EVENT_TYPE) is
			-- Set left_target_type to `arg'.
		require
			arg_not_void: arg /= Void
			-- arg is the type of one of the events returned by the
			-- components feature of each event produced by left_analyzer
		do
			left_target_type := arg
		ensure
			left_target_type_set: left_target_type = arg and
				left_target_type /= Void
		end

feature -- Basic operations

	execute is
		local
			left_events, right_events: CHAIN [MARKET_EVENT]
		do
			!LINKED_LIST [MARKET_EVENT]!product.make
			left_analyzer.execute
			right_analyzer.execute
			left_events := left_analyzer.product
			right_events := right_analyzer.product
			from
				left_events.start
				right_events.start
			until
				right_events.exhausted
			loop
				generate_events (right_events.item, left_events)
				right_events.forth
			end
		end

feature {NONE} -- Implementation

	target_date (e: MARKET_EVENT): DATE_TIME is
			-- The time stamp of the component of `e' that matches
			-- left_target_type
		require
			left_target_type /= Void
		local
			l: LIST [MARKET_EVENT]
		do
			from
				l := e.components
				l.start
			until
				Result /= Void or l.exhausted
			loop
				if l.item.type = left_target_type then
					Result := l.item.time_stamp
				end
				l.forth
			end
			check
				type_in_e_s_components: Result /= Void
			end
			-- If a defect exists that causes no match to be found for
			-- left_target_type in the above loop and if assertion checking is
			-- off, Result will be Void.  In this case, set Result to a
			-- very late date to cause the loop (in generate_events) that
			-- depends on this value to terminate to avoid the possibility
			-- of an infinite loop.
			if Result = Void then
				!!Result.make (9999, 1, 1, 0, 0, 0)
				print (concatenation (<<"Error occurred in ", generator,
						" in feature target_date: left_target_type ",
						left_target_type.name, " (ID: ", left_target_type.id,
						") was not found in event ", e.name,
						"'s components.">>))
			end
		end

	three_way_comparison (rt_intrvl: INTERVAL [DATE_TIME];
				left: MARKET_EVENT): INTEGER is
			-- Comparison of `rt_intrvl' to the target time of event `left'.
			-- Result is -1 if `rt_intrvl' comes before `left', 0 if it
			-- intersects with `left', and 1 if it comes after `left'.
			-- The target time from `left', used for the comparison, is
			-- taken from the time stamp of the component of `left' that
			-- matches left_target_type, unless left_target_type is Void,
			-- in which case, it is `left's time stamp.
		require
			not_void: rt_intrvl /= Void and left /= Void
		local
			left_date: DATE_TIME
		do
			if left_target_type /= Void then
				left_date := target_date (left)
			else
				left_date := left.time_stamp
			end
			if rt_intrvl.strict_before (left_date) then
				Result := -1
			elseif rt_intrvl.strict_after (left_date) then
				Result := 1
			else
				check
					intersects: rt_intrvl.intersects (left_date - left_date)
				end
				Result := 0
			end
		end

	generate_events (e: MARKET_EVENT; l: CHAIN [MARKET_EVENT]) is
			-- Generate an event from each event in `l' that intersects with
			-- `e's extended interval.
		require
			not_void: e /= Void and l /= Void
			product_not_void: product /= Void
		local
			intrvl: INTERVAL [DATE_TIME]
			first_match: CURSOR
			comp_result: INTEGER
		do
			from
				if not l.exhausted then
					intrvl := extended_event_interval (e)
					comp_result := three_way_comparison (intrvl, l.item)
				end
			until
				l.exhausted or else comp_result = -1
			loop
				if comp_result = 0 then
					if first_match = Void then
						first_match := l.cursor
					end
					generate_event_pair (l.item, e)
				end
				l.forth
				if not l.exhausted then
					comp_result := three_way_comparison (intrvl, l.item)
				end
			end
			if first_match /= Void then
				-- Set l's cursor back to that of the first match found for
				-- e, so that it will be positioned to find the first match
				-- for the next call to generate_events.
				l.go_to (first_match)
			end
		end

	extended_event_interval (e: MARKET_EVENT): INTERVAL [DATE_TIME] is
			-- The interval formed from `e's time stamp plus
			-- `before_extension' and `e's time stamp plus after_extension
		require
			e /= Void
		do
			!!Result.make (e.time_stamp + before_extension,
							e.time_stamp + after_extension)
		end

	generate_event_pair (left, right: MARKET_EVENT) is
			-- Generate a MARKET_EVENT_PAIR with left and right elements set
			-- to `left' and `right', respectively and add it to `product'.
		require
			product_not_void: product /= Void
		local
			e: MARKET_EVENT_PAIR
		do
			!!e.make (left, right, "Event pair", event_type)
			product.extend (e)
		end

invariant

	analyzers_not_void: left_analyzer /= Void and right_analyzer /= Void
	extensions_not_void: before_extension /= Void and after_extension /= Void

end -- class COMPOUND_EVENT_GENERATOR
