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
			slow_stoch_up, slow_stoch_down, close_MA: MARKET_EVENT_GENERATOR
			stoch_pctD_up, stoch_pctD_down: MARKET_EVENT_GENERATOR
			stoch_pctK_up, stoch_pctK_down: MARKET_EVENT_GENERATOR
			slow_up_up, slow_down_down: MARKET_EVENT_GENERATOR
			stochD_up_up, stochD_down_down: MARKET_EVENT_GENERATOR
			stochK_up_up, stochK_down_down: MARKET_EVENT_GENERATOR
			macd_up, macd_down: TWO_VARIABLE_FUNCTION_ANALYZER
		do
			!LINKED_LIST [MARKET_EVENT_GENERATOR]!product.make
			slow_stoch_up := slow_stochastic_analyzer (
					"Slow Stochastic %%D - -> + slope change event", true)
			product.extend (slow_stoch_up) -- index 1
			slow_stoch_down := slow_stochastic_analyzer (
					"Slow Stochastic %%D + -> - slope change event", false)
			product.extend (slow_stoch_down) -- index 2

			stoch_pctD_up := stochastic_pctD_analyzer (
					"Stochastic %%D - -> + slope change event", true)
			product.extend (stoch_pctD_up) -- index 3
			stoch_pctD_down := stochastic_pctD_analyzer (
					"Stochastic %%D + -> - slope change event", false)
			product.extend (stoch_pctD_down) -- index 4

			stoch_pctK_up := stochastic_pctK_analyzer (
					"Stochastic %%K - -> + slope change event", true)
			product.extend (stoch_pctK_up) -- index 5
			stoch_pctK_down := stochastic_pctK_analyzer (
					"Stochastic %%K + -> - slope change event", false)
			product.extend (stoch_pctK_down) -- index 6

			macd_up := macd_analyzer (
					"MACD difference/signal crossover event - below to above")
			product.extend (macd_up) -- index 7
			macd_down := macd_analyzer (
					"MACD difference/signal crossover event - above to below")
			product.extend (macd_down) -- index 8
			macd_up.set_below_to_above_only
			macd_down.set_above_to_below_only
			close_MA := close_MA_analyzer
			product.extend (close_MA) -- index 9
			-- For testing, simply re-use the stochastic analyzer and the
			-- macd analyzer in the compound analyzer.
			-- MACD upward crossover and slow stochastic %D upward slope change:
			slow_up_up := compound_analyzer (macd_up, slow_stoch_up,
								concatenation (<<"[", macd_up.event_type.name,
									"] / [",
									slow_stoch_up.event_type.name, "]">>),
								-- This last parameter can just be Void, but
								-- the type is supplied here for testing
								-- purposes - result should be the same:
									macd_up.event_type)
			product.extend (slow_up_up) -- index 10
			-- MACD downward crossover and slow stochastic %D downward
			-- slope change:
			slow_down_down := compound_analyzer (macd_down, slow_stoch_down,
								concatenation (<<"[",
								macd_down.event_type.name, "] / [",
								slow_stoch_down.event_type.name, "]">>), Void)
			product.extend (slow_down_down) -- index 11

			-- MACD upward crossover and stochastic %D upward slope change:
			stochD_up_up := compound_analyzer (macd_up, stoch_pctD_up,
								concatenation (<<"[", macd_up.event_type.name,
									"] / [", stoch_pctD_up.event_type.name,
									"]">>), Void)
			product.extend (stochD_up_up) -- index 12
			-- MACD downward crossover and stochastic %D downward slope change:
			stochD_down_down := compound_analyzer (macd_down, stoch_pctD_down,
								concatenation (<<"[",
								macd_down.event_type.name, "] / [",
								stoch_pctD_down.event_type.name, "]">>), Void)
			product.extend (stochD_down_down) -- index 13

			-- MACD upward crossover and stochastic %K upward slope change:
			stochK_up_up := compound_analyzer (macd_up, stoch_pctK_up,
								concatenation (<<"[", macd_up.event_type.name,
									"] / [", stoch_pctK_up.event_type.name,
									"]">>), Void)
			product.extend (stochK_up_up) -- index 14
			-- MACD downward crossover and stochastic %K downward slope change:
			stochK_down_down := compound_analyzer (macd_down, stoch_pctK_down,
								concatenation (<<"[",
								macd_down.event_type.name, "] / [",
								stoch_pctK_down.event_type.name, "]">>), Void)
			product.extend (stochK_down_down) -- index 15

			-- A couple compound-compound analyzers
			product.extend (compound_analyzer (slow_up_up, close_MA,
							concatenation (<<"[",
								slow_up_up.event_type.name, "] / [",
								close_MA.event_type.name, "]">>),
								slow_stoch_up.event_type))
								-- index 16
			product.extend (compound_analyzer (slow_down_down, close_MA,
							concatenation (<<"[",
								slow_down_down.event_type.name, "] / [",
								close_MA.event_type.name, "]">>), Void))
								-- index 17
		end

feature {NONE} -- Hard-coded market analyzer building procedures

	Previous_slope_offset: INTEGER is -1
			-- Offset value for "previous" slope analyzer
	
	Neg_to_pos, Pos_to_neg, Both: INTEGER is unique
			-- Slope specifications

	set_slope_spec (op: SIGN_ANALYZER; direction: INTEGER) is
			-- Add a slope spec. for the specified direction to op.
		do
			inspect
				direction
			when Neg_to_pos then
				-- negative to positive slope change:
				op.add_sign_change_spec (<<-1, 1>>)
			when Pos_to_neg then
				op.add_sign_change_spec (<<1, -1>>)
			when Both then
				op.add_sign_change_spec (<<-1, 1>>)
				op.add_sign_change_spec (<<1, -1>>)
			end
		end

	slow_stochastic_analyzer (name: STRING; slope_up: BOOLEAN):
				ONE_VARIABLE_FUNCTION_ANALYZER is
			-- Analyzer of slow stochastic %D
		local
			l: LIST [MARKET_FUNCTION]
			f: MARKET_FUNCTION
			slope_analyzer: SLOPE_ANALYZER
			sign_analyzer: SIGN_ANALYZER
			previous_cmd: SETTABLE_OFFSET_COMMAND
			blc: BASIC_LINEAR_COMMAND
			boundary: CONSTANT
			relation: BINARY_OPERATOR [BOOLEAN, REAL]
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
			-- Clone the original because its innermost function may be
			-- changed during processing; so the original won't be changed.
			f := deep_clone (l.item)
			!!slope_analyzer.make (f.output)
			!!previous_cmd.make (f.output, slope_analyzer)
			previous_cmd.set_offset (Previous_slope_offset)
			!!sign_analyzer.make (previous_cmd, slope_analyzer, false)
			!!blc.make (f.output)
			-- If slope_up (negative-to-positive slope change) then set up
			-- for detecting slope change below 30; else set up for
			-- detecting slope change (pos-to-neg) above 70.
			if slope_up then
				!!boundary.make (30)
				!LT_OPERATOR!relation.make (blc, boundary)
				set_slope_spec (sign_analyzer, Neg_to_pos)
			else
				!!boundary.make (70)
				!GT_OPERATOR!relation.make (blc, boundary)
				set_slope_spec (sign_analyzer, Pos_to_neg)
			end
			!!and_op.make (sign_analyzer, relation)
			!!Result.make (f, and_op, name, period_types @ "daily")
			-- Set offset such that the cursor position used by previous_cmd,
			-- which has a negative offset, will always be valid.
			Result.set_offset (Previous_slope_offset.abs)
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

	stochastic_pctD_analyzer (name: STRING; slope_up: BOOLEAN):
				ONE_VARIABLE_FUNCTION_ANALYZER is
			-- Analyzer of (fast) stochastic %D
		local
			l: LIST [MARKET_FUNCTION]
			f: MARKET_FUNCTION
			slope_analyzer: SLOPE_ANALYZER
			sign_analyzer: SIGN_ANALYZER
			previous_cmd: SETTABLE_OFFSET_COMMAND
			blc: BASIC_LINEAR_COMMAND
			boundary: CONSTANT
			relation: BINARY_OPERATOR [BOOLEAN, REAL]
			and_op: AND_OPERATOR
		do
			l := function_library
			check l /= Void end
			from
				l.start
			until
				l.item.name.is_equal ("Stochastic %%D") or l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			-- Clone the original because its innermost function may be
			-- changed during processing; so the original won't be changed.
			f := deep_clone (l.item)
			!!slope_analyzer.make (f.output)
			!!previous_cmd.make (f.output, slope_analyzer)
			previous_cmd.set_offset (Previous_slope_offset)
			!!sign_analyzer.make (previous_cmd, slope_analyzer, false)
			!!blc.make (f.output)
			-- If slope_up (negative-to-positive slope change) then set up
			-- for detecting slope change below 30; else set up for
			-- detecting slope change (pos-to-neg) above 70.
			if slope_up then
				!!boundary.make (30)
				!LT_OPERATOR!relation.make (blc, boundary)
				set_slope_spec (sign_analyzer, Neg_to_pos)
			else
				!!boundary.make (70)
				!GT_OPERATOR!relation.make (blc, boundary)
				set_slope_spec (sign_analyzer, Pos_to_neg)
			end
			!!and_op.make (sign_analyzer, relation)
			!!Result.make (f, and_op, name, period_types @ "daily")
			-- Set offset such that the cursor position used by previous_cmd,
			-- which has a negative offset, will always be valid.
			Result.set_offset (Previous_slope_offset.abs)
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

	stochastic_pctK_analyzer (name: STRING; slope_up: BOOLEAN):
				ONE_VARIABLE_FUNCTION_ANALYZER is
			-- Analyzer of (fast) stochastic %K
		local
			l: LIST [MARKET_FUNCTION]
			f: MARKET_FUNCTION
			slope_analyzer: SLOPE_ANALYZER
			sign_analyzer: SIGN_ANALYZER
			previous_cmd: SETTABLE_OFFSET_COMMAND
			blc: BASIC_LINEAR_COMMAND
			boundary: CONSTANT
			relation: BINARY_OPERATOR [BOOLEAN, REAL]
			and_op: AND_OPERATOR
		do
			l := function_library
			check l /= Void end
			from
				l.start
			until
				l.item.name.is_equal ("Stochastic %%K") or l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			-- Clone the original because its innermost function may be
			-- changed during processing; so the original won't be changed.
			f := deep_clone (l.item)
			!!slope_analyzer.make (f.output)
			!!previous_cmd.make (f.output, slope_analyzer)
			previous_cmd.set_offset (Previous_slope_offset)
			!!sign_analyzer.make (previous_cmd, slope_analyzer, false)
			!!blc.make (f.output)
			-- If slope_up (negative-to-positive slope change) then set up
			-- for detecting slope change below 30; else set up for
			-- detecting slope change (pos-to-neg) above 70.
			if slope_up then
				!!boundary.make (30)
				!LT_OPERATOR!relation.make (blc, boundary)
				set_slope_spec (sign_analyzer, Neg_to_pos)
			else
				!!boundary.make (70)
				!GT_OPERATOR!relation.make (blc, boundary)
				set_slope_spec (sign_analyzer, Pos_to_neg)
			end
			!!and_op.make (sign_analyzer, relation)
			!!Result.make (f, and_op, name, period_types @ "daily")
			-- Set offset such that the cursor position used by previous_cmd,
			-- which has a negative offset, will always be valid.
			Result.set_offset (Previous_slope_offset.abs)
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

	macd_analyzer (name: STRING): TWO_VARIABLE_FUNCTION_ANALYZER is
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
			-- Clone the original because its innermost function may be
			-- changed during processing; so the original won't be changed.
			f1 := deep_clone (l.item)
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
			-- Clone the original because its innermost function may be
			-- changed during processing; so the original won't be changed.
			f2 := deep_clone (l.item)
			!!Result.make (f1, f2, name, period_types @ "weekly")
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
			-- Clone the original because its innermost function may be
			-- changed during processing; so the original won't be changed.
			f1 := deep_clone (l.item)
			from
				l.start
			until
				l.item.name.is_equal ("Simple Moving Average") or l.exhausted
			loop
				l.forth
			end
			check not l.exhausted end
			-- Clone the original because its innermost function may be
			-- changed during processing; so the original won't be changed.
			f2 := deep_clone (l.item)
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
