indexing
	description:
		"Builder of a list of market functions"
	note:
		"Hard-coded for testing for now, but may evolve into a legitimate %
		%class"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class FUNCTION_ANALYZER_BUILDER inherit

	FACTORY
		redefine
			product
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

	product: LIST [FUNCTION_ANALYZER]

	function_library: LIST [MARKET_FUNCTION]

feature -- Basic operations

	execute is
		do
			!LINKED_LIST [FUNCTION_ANALYZER]!product.make
			product.extend (stochastic_analyzer)
			product.extend (macd_analyzer)
		end

feature {NONE} -- Hard-coded market analyzer building procedures

	stoch_slope_spec: ARRAY [INTEGER] is
		do
			!!Result.make (1, 2)
			-- Specify a negative to positive slope change:
			Result := <<-1, 1>>
		ensure
			Result.count = 2
		end

	stochastic_analyzer: FUNCTION_ANALYZER is
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
			previous_cmd.set_offset (-1)
			!!sign_analyzer.make (previous_cmd, slope_analyzer, false)
			sign_analyzer.add_sign_change_spec (stoch_slope_spec)
			!!blc.make (f.output)
			!!bottom_limit.make (30)
			!!less_than.make (blc, bottom_limit)
			!!and_op.make (sign_analyzer, less_than)
			!ONE_VARIABLE_FUNCTION_ANALYZER!Result.make (f, and_op,
				"Stochastic - -> + slope change event")
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

	macd_analyzer: FUNCTION_ANALYZER is
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
			l := function_library
			check l /= Void end
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
			!TWO_VARIABLE_FUNCTION_ANALYZER!Result.make (f1, f2,
				"MACD difference/signal crossover event")
			--!!!!!!!!!!!!!!Remember that Result's start_date_time needs
			--!!!!!!!!to be set to a reasonable value!!!!!!!!!!
		end

end -- FUNCTION_ANALYZER_BUILDER
