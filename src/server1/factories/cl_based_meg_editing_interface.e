indexing
	description:
		"Builder of a list of market functions"
	note:
		"Hard-coded for testing for now, but may evolve into a legitimate %
		%class"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_EVENT_GENERATOR_BUILDER inherit

	FACTORY
		redefine
			product
		end

	GLOBAL_SERVICES
		rename
			function_library as flib_not_currently_used_but_may_be_later --!!!
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (l: LIST [MARKET_FUNCTION]) is
		require
			not_void: l /= Void
		do
			function_library := l
		end

feature -- Access

	product: LIST [MARKET_EVENT_GENERATOR]

	function_library: LIST [MARKET_FUNCTION]

feature -- Basic operations

	execute is
		local
			test_left_target: BOOLEAN
		do
			!LINKED_LIST [MARKET_EVENT_GENERATOR]!product.make
			test_left_target := true
			product.extend (stochastic_analyzer)
			product.extend (macd_analyzer)
			product.extend (close_MA_analyzer)
			-- For testing, simply re-use the stochastic analyzer and the
			-- macd analyzer in the compound analyzer.
			if test_left_target then
				product.extend (compound_analyzer (product @ 2, product @ 1,
							concatenation (<<"[",
								(product @ 2).event_type.name, "] / [",
								(product @ 1).event_type.name, "]">>),
								(product @ 2).event_type))
			else
				product.extend (compound_analyzer (product @ 2, product @ 1,
							concatenation (<<"[",
								(product @ 2).event_type.name, "] / [",
								(product @ 1).event_type.name, "]">>), Void))
			end
			if test_left_target then
				product.extend (compound_analyzer (product @ 4, product @ 3,
							concatenation (<<"[",
								(product @ 4).event_type.name, "] / [",
								(product @ 3).event_type.name, "]">>),
								(product @ 1).event_type))
			else
				product.extend (compound_analyzer (product @ 4, product @ 3,
							concatenation (<<"[",
								(product @ 4).event_type.name, "] / [",
								(product @ 3).event_type.name, "]">>), Void))
			end
		end

feature {NONE} -- Hard-coded market analyzer building procedures

	Previous_slope_offset: INTEGER is -1
			-- Offset value for "previous" slope analyzer

	stoch_slope_spec: ARRAY [INTEGER] is
		do
			!!Result.make (1, 2)
			-- Specify a negative to positive slope change:
			Result := <<-1, 1>>
		ensure
			Result.count = 2
		end

	stochastic_analyzer: ONE_VARIABLE_FUNCTION_ANALYZER is
			-- Analyzer of slow stochastic
		local
			l: LIST [MARKET_FUNCTION]
			f: MARKET_FUNCTION
			slope_analyzer: SLOPE_ANALYZER
			previous_cmd: SETTABLE_OFFSET_COMMAND
			sign_analyzer: SIGN_ANALYZER
			blc: BASIC_LINEAR_COMMAND
			bottom_limit: CONSTANT
			less_than: LT_OPERATOR
			and_op: AND_OPERATOR
		do
			l := function_library
			check l /= Void end
			from
				l.start
			until
				l.item.name.is_equal ("Slow Stochastic %%D") or l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			f := l.item
			!!slope_analyzer.make (f.output)
			!!previous_cmd.make (f.output, slope_analyzer)
			previous_cmd.set_offset (Previous_slope_offset)
			!!sign_analyzer.make (previous_cmd, slope_analyzer, false)
			sign_analyzer.add_sign_change_spec (stoch_slope_spec)
			!!blc.make (f.output)
			!!bottom_limit.make (30)
			!!less_than.make (blc, bottom_limit)
			!!and_op.make (sign_analyzer, less_than)
			!!Result.make (f, and_op,
				"Stochastic - -> + slope change event", period_types @ "daily")
			-- Set offset such that the cursor position used by previous_cmd,
			-- which has a negative offset, will always be valid.
			Result.set_offset (Previous_slope_offset.abs)
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

	macd_analyzer: TWO_VARIABLE_FUNCTION_ANALYZER is
			-- Analyzer of MACD signal line crossing difference
		local
			l: LIST [MARKET_FUNCTION]
			f1, f2: MARKET_FUNCTION
		do
			l := function_library
			check l /= Void end
			from
				l.start
			until
				l.item.name.is_equal ("MACD Difference") or l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			f1 := l.item
			from
				l.start
			until
				l.item.name.is_equal
					("MACD Signal Line (EMA of MACD Difference)") or
					l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			f2 := l.item
			!!Result.make (f1, f2,
				"MACD difference/signal crossover event",
				period_types @ "weekly")
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

	close_MA_analyzer: TWO_VARIABLE_FUNCTION_ANALYZER is
			-- Analyzer of closing price crossing MA
		local
			l: LIST [MARKET_FUNCTION]
			f1, f2: MARKET_FUNCTION
		do
			l := function_library
			check l /= Void end
			from
				l.start
			until
				l.item.name.is_equal ("Market Close Data") or l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			f1 := l.item
			from
				l.start
			until
				l.item.name.is_equal ("Simple Moving Average") or l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			f2 := l.item
			!!Result.make (f1, f2,
				"Closing Price/Moving Average crossover event",
				period_types @ "daily")
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

	compound_analyzer (left, right: MARKET_EVENT_GENERATOR; name: STRING;
		left_target_type: EVENT_TYPE):
				COMPOUND_EVENT_GENERATOR is
			-- Compound analyzer with `left' and `right' as its components
			-- If left_target_type is not Void, set Result's left_target_type
			-- to it.
		require
			not_void: left /= Void and right /= Void and name /= Void
		local
			before: DATE_TIME_DURATION
		do
			-- Hard-code duration to 4 weeks:
			!!before.make (0, 0, 28, 0, 0, 0)
			!!Result.make (left, right, name)
			Result.set_before_extension (before)
			if left_target_type /= Void then
				Result.set_left_target_type (left_target_type)
			end
			-- Leave Result's after extension as 0.
		end

end -- MARKET_EVENT_GENERATOR_BUILDER
