indexing
	description:
		"Builder of a list of market functions"
	note:
		"Hard-coded for testing for now, but may evolve into a legitimate %
		%class"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class FUNCTION_BUILDER inherit

	FACTORY
		redefine
			product
		end

feature -- Access

	product: LIST [MARKET_FUNCTION]

	Simple_MA_n: INTEGER is 10
	EMA_n: INTEGER is 10
	Smaller_MACD_EMA_n: INTEGER is 12
	Larger_MACD_EMA_n: INTEGER is 26
	MACD_Signal_Line_EMA_n: INTEGER is 9
	Momentum_n: INTEGER is 7
	Rate_of_Change_n: INTEGER is 10
	StochasticK_n: INTEGER is 5
	StochasticD_n: INTEGER is 3
	Williams_n: INTEGER is 7

feature -- Basic operations

	execute (f: MARKET_FUNCTION) is
		local
			l: LINKED_LIST [MARKET_FUNCTION]
		do
			!!l.make
			l.extend (simple_ma (f, Simple_MA_n, "Simple Moving Average"))
			l.extend (ema (f, EMA_n, "Exponential Moving Average"))
			l.extend (ma_diff ((ema (f, Smaller_MACD_EMA_n, "Short EMA")),
								(ema (f, Larger_MACD_EMA_n, "Long EMA")),
								"MACD Difference"))
			l.extend (ema (l.last, MACD_Signal_Line_EMA_n,
						"MACD Signal Line (EMA of MACD Difference)"))
			l.extend (ma_diff (l.i_th (l.count - 1), l.last, "MACD Histogram"))
			l.extend (momentum (f, Momentum_n, "Momentum", "SUBTRACTION"))
			l.extend (momentum (f, Rate_of_Change_n, "Rate of Change",
						"DIVISION"))
			l.extend (williams_percent_R (f, Williams_n, "Williams %%R"))
			l.extend (stochastic_percent_K (f, StochasticK_n, "Stochastic %%K"))
			l.extend (stochastic_percent_D (f, StochasticK_n, StochasticD_n,
											"Stochastic %%D"))
			l.extend (simple_ma (l.last, StochasticD_n,
											"Slow Stochastic %%D"))
			product := l
		end

feature -- Status report

	arg_mandatory: BOOLEAN is true

feature {NONE} -- Hard-coded market function building procedures

	simple_ma (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
						STANDARD_MOVING_AVERAGE is
			-- Make a simple moving average function.
		local
			cmd: BASIC_NUMERIC_COMMAND
		do
			!!cmd
			!!Result.make (f, cmd, n)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

	ema (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
				EXPONENTIAL_MOVING_AVERAGE is
			-- Make an exponential moving average function for testing.
		local
			cmd: BASIC_NUMERIC_COMMAND
			e: MA_EXPONENTIAL
		do
			!!cmd
			!!e.make (1)
			!!Result.make (f, cmd, e, n)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.n = n and Result.name = name
		end

	ma_diff (f1, f2: MARKET_FUNCTION; name: STRING): TWO_VARIABLE_FUNCTION is
			-- A function that gives the difference between -- `f1' and `f2'
			-- Uses a BASIC_LINEAR_COMMAND to obtain the values from `f1'
			-- and `f2' to be subtracted.
		require
			not_void: f1 /= Void and f2 /= Void
			o_not_void: f1.output /= Void and f2.output /= Void
		local
			sub: SUBTRACTION
			cmd1: BASIC_LINEAR_COMMAND
			cmd2: BASIC_LINEAR_COMMAND
		do
			!!cmd1.make (f1.output)
			!!cmd2.make (f2.output)
			!!sub.make_with_operands (cmd1, cmd2)
			!!Result.make (f1, f2, sub)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

	momentum (f: MARKET_FUNCTION; n: INTEGER; name: STRING;
				operator_type: STRING): MOMENTUM_FUNCTION is
			-- A momentum function
		local
			operator: BINARY_NUMERIC_OPERATOR
			close: CLOSING_PRICE
			close_minus_n: MINUS_N_COMMAND
		do
			!!close; !!close_minus_n.make (f.output, n)
			if operator_type.is_equal ("SUBTRACTION") then
				!SUBTRACTION!operator.make_with_operands (close, close_minus_n)
			else
				check operator_type.is_equal ("DIVISION") end
				!DIVISION!operator.make_with_operands (close, close_minus_n)
			end
			!!Result.make (f, operator, close_minus_n, n)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.n = n and Result.name = name
		end

	williams_percent_R (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
				N_RECORD_ONE_VARIABLE_FUNCTION is
			-- A Williams %R function
		local
			d: DIVISION
			s1: SUBTRACTION
			s2: SUBTRACTION
			highest: HIGHEST_HIGH
			lowest: LOWEST_LOW
			close: CLOSING_PRICE
		do
			!!close
			!!highest.make (f.output, n)
			!!lowest.make (f.output, n)
			!!s1.make_with_operands (highest, close)
			!!s2.make_with_operands (highest, lowest)
			!!d.make_with_operands (s1, s2)
			!!Result.make (f, d, n)
			Result.set_name (name)
			check Result.n = highest.n and Result.n = lowest.n end
		ensure
			initialized: Result /= Void and Result.n = n and Result.name = name
		end

	stochastic_percent_K (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
				N_RECORD_ONE_VARIABLE_FUNCTION is
			-- A Stochastic %K function
		local
			d: DIVISION
			s1: SUBTRACTION
			s2: SUBTRACTION
			highest: HIGHEST_HIGH
			lowest: LOWEST_LOW
			close: CLOSING_PRICE
		do
			!!close
			!!highest.make (f.output, n)
			!!lowest.make (f.output, n)
			!!s1.make_with_operands (close, lowest);
			!!s2.make_with_operands (highest, lowest)
			!!d.make_with_operands (s1, s2)
			!!Result.make (f, d, n)
			Result.set_name (name)
			check Result.n = lowest.n and Result.n = highest.n end
		ensure
			initialized: Result /= Void and Result.n = n and Result.name = name
		end

	stochastic_percent_D (f: MARKET_FUNCTION; inner_n, outer_n: INTEGER;
				name: STRING): TWO_VARIABLE_FUNCTION is
			-- Make a Stochastic %D calculation function for testing.
		local
			div: DIVISION
			sub1: SUBTRACTION
			sub2: SUBTRACTION
			basic1: BASIC_LINEAR_COMMAND
			basic2: BASIC_LINEAR_COMMAND
			close_low_function: N_RECORD_ONE_VARIABLE_FUNCTION
			high_low_function: N_RECORD_ONE_VARIABLE_FUNCTION
			ma1, ma2: STANDARD_MOVING_AVERAGE
			cmd: BASIC_NUMERIC_COMMAND
			highest: HIGHEST_HIGH
			lowest: LOWEST_LOW
			close: CLOSING_PRICE
		do
			!!cmd
			!!highest.make (f.output, inner_n)
			!!lowest.make (f.output, inner_n)
			!!close
			!!sub1.make_with_operands (close, lowest);
			!!sub2.make_with_operands (highest, lowest)
			!!close_low_function.make (f, sub1, inner_n)
			!!high_low_function.make (f, sub2, inner_n)
			close_low_function.process (Void)
			high_low_function.process (Void)
			!!ma1.make (close_low_function, cmd, outer_n)
			!!ma2.make (high_low_function, cmd, outer_n)
			ma1.process (Void)
			ma2.process (Void)
			!!basic1.make (ma1.output); !!basic2.make (ma2.output)
			!!div.make_with_operands (basic1, basic2)
			!!Result.make (ma1, ma2, div)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

end -- FUNCTION_BUILDER
