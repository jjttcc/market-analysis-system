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

	EVENT_GENERATOR

creation

	make

feature {NONE} -- Initialization

	make (la, ra: EVENT_GENERATOR; event_type_name: STRING) is
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
		end

feature -- Access

	left_analyzer, right_analyzer: EVENT_GENERATOR
			-- Contained function analyzers

	before_extension, after_extension: DATE_TIME_DURATION
			-- Before and after time extensions to the current event - used
			-- to enlarge the time interval of each event produced by
			-- right_analyzer by a specified amount that will produce a
			-- match with an event produced by left_analyzer if this time
			-- interval intersects with the left_analyzer event's start and
			-- end times.

feature -- Status setting

	set_before_extension (arg: DATE_TIME_DURATION) is
			-- Set before_extension to -`arg'.
		require
			arg_not_void: arg /= Void
		do
			before_extension := -arg
		ensure
			not_void: before_extension /= Void
			before_extension_opposite: before_extension = -arg
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

feature -- Basic operations

	execute is
		local
			left_events, right_events: CHAIN [MARKET_EVENT]
		do
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

	three_way_comparison (intrvl: INTERVAL [DATE_TIME];
				l: CHAIN [MARKET_EVENT]): INTEGER is
			-- How does `intrvl' compare with the interval formed from the
			-- start and end dates of `l's current item?  Result is -1 if 
			-- `intrvl' comes before `l's current item, 0 if it intersects with
			-- it, and 1 if it comes after.
		require
			not_void: intrvl /= Void and l /= Void
			not_l_off: not l.off
		do
			if intrvl.intersects (l.item.end_date - l.item.start_date) then
				Result := 0
			elseif intrvl.end_bound < l.item.start_date then
				Result := -1
			else
				check
					int_starts_after_item: intrvl.start_bound > l.item.end_date
				end
				Result := 1
			end
		end

	generate_events (e: MARKET_EVENT; l: CHAIN [MARKET_EVENT]) is
			-- Generate an event from each event in `l' that intersects with
			-- `e's extended interval.
		require
			not_void: e /= Void and l /= Void
		local
			intrvl: INTERVAL [DATE_TIME]
			first_match: CURSOR
			comp_result: INTEGER
		do
			from
				if not l.exhausted then
					intrvl := extended_event_interval (e)
					comp_result := three_way_comparison (intrvl, l)
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
					comp_result := three_way_comparison (intrvl, l)
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
			-- The interval formed from `e's start date plus
			-- `before_extension' and `e's end date plus after_extension
		require
			e /= Void
		do
			!!Result.make (e.start_date + before_extension,
							e.end_date + after_extension)
		end

	generate_event_pair (left, right: MARKET_EVENT) is
			-- Generate a MARKET_EVENT_PAIR with left and right elements set
			-- to `left' and `right', respectively and add it to `product'.
		local
			e: MARKET_EVENT_PAIR
		do
			!!e.make (left, right, "Event pair", event_type)
			-- !!!Add more info to e?
			product.extend (e)
		end

invariant

	analyzers_not_void: left_analyzer /= Void and right_analyzer /= Void
	extensions_not_void: before_extension /= Void after_extension /= Void

end -- class COMPOUND_EVENT_GENERATOR
