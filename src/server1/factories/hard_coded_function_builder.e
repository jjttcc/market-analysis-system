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

creation

	make

feature

	make (f: MARKET_FUNCTION) is
		require
			not_void: f /= Void
		do
			innermost_function := f
		ensure
			set: innermost_function = f and innermost_function /= Void
		end

feature -- Access

	product: LIST [MARKET_FUNCTION]

	innermost_function: MARKET_FUNCTION
			-- The function that provides input data to all manufactured
			-- functions

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
	RSI_n: INTEGER is 7

feature -- Status setting

	set_innermost_function (arg: MARKET_FUNCTION) is
			-- Set innermost_function to `arg'.
		require
			arg /= Void
		do
			innermost_function := arg
		ensure
			innermost_function_set: innermost_function = arg and
									innermost_function /= Void
		end

feature -- Basic operations

	execute is
		local
			l: LINKED_LIST [MARKET_FUNCTION]
			f: MARKET_FUNCTION
		do
			f := innermost_function
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
			l.extend (rsi (f, RSI_n, "Relative Strength Index"))
			product := l
		end

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
			close: CLOSING_PRICE
		do
			!!close
			!!cmd1.make (f1.output)
			!!cmd2.make (f2.output)
			!!sub.make (cmd1, cmd2)
			!!Result.make (f1, f2, sub)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

	momentum (f: MARKET_FUNCTION; n: INTEGER; name: STRING;
				operator_type: STRING): N_RECORD_ONE_VARIABLE_FUNCTION is
			-- A momentum function
		local
			operator: BINARY_OPERATOR [REAL, REAL]
			close: CLOSING_PRICE
			close_minus_n: MINUS_N_COMMAND
		do
			!!close; !!close_minus_n.make (f.output, close, n)
			if operator_type.is_equal ("SUBTRACTION") then
				!SUBTRACTION!operator.make (close, close_minus_n)
			else
				check operator_type.is_equal ("DIVISION") end
				!DIVISION!operator.make (close, close_minus_n)
			end
			!!Result.make (f, operator, n)
			Result.set_effective_offset (1)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.n = n and Result.name = name
		end

	rsi (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
				N_RECORD_ONE_VARIABLE_FUNCTION is
			-- RSI = 100 - (100 / (1 + RS))
			-- RS = (average n up closes ) / (average n down closes)
		local
			up_closes, down_closes: MINUS_N_COMMAND
			up_adder, down_adder: LINEAR_SUM
			up_boolclient, down_boolclient: BOOLEAN_NUMERIC_CLIENT
			lt_op: LT_OPERATOR
			gt_op: GT_OPERATOR
			offset1, offset2: SETTABLE_OFFSET_COMMAND
			close: CLOSING_PRICE
			zero, one_hundred, one: CONSTANT
			nvalue: N_VALUE_COMMAND
			upsub, downsub, outer_sub: SUBTRACTION
			rs_div, maindiv, upavg, downavg: DIVISION
			one_plus_rs: ADDITION
		do
			!!close; !!zero.make (0)
			!!one_hundred.make (100); !!one.make (1); !!nvalue.make (n)
			!!offset1.make (f.output, close); !!offset2.make (f.output, close)
			offset2.set_offset (1)
			!!lt_op.make (offset1, offset2)
			!!upsub.make (offset2, offset1)
			!!up_boolclient.make (lt_op, upsub, zero)
			!!up_adder.make (f.output, up_boolclient, n)
			!!up_closes.make (f.output, up_adder, n)
			!!upavg.make (up_closes, nvalue)

			!!gt_op.make (offset1, offset2)
			-- Notice that order of arguments is different:
			!!downsub.make (offset1, offset2)
			!!down_boolclient.make (gt_op, downsub, zero)
			!!down_adder.make (f.output, down_boolclient, n)
			!!down_closes.make (f.output, down_adder, n)
			!!downavg.make (down_closes, nvalue)

			!!rs_div.make (upavg, downavg) -- RS: up avg / down avg
			!!one_plus_rs.make (rs_div, one) -- 1 + RS
			!!maindiv.make (one_hundred, one_plus_rs) -- 100 / (1 + RS)
			!!outer_sub.make (one_hundred, maindiv) -- 100 - (100 / (1 + RS))
			!!Result.make (f, outer_sub, n)
			Result.set_effective_offset (1)
			Result.set_name (name)
		end

	williams_percent_R (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
				N_RECORD_ONE_VARIABLE_FUNCTION is
			-- A Williams %R function
		local
			m: MULTIPLICATION -- Used to convert value to percent.
			d: DIVISION
			s1: SUBTRACTION
			s2: SUBTRACTION
			highest: HIGHEST_VALUE
			lowest: LOWEST_VALUE
			high: HIGH_PRICE
			low: LOW_PRICE
			close: CLOSING_PRICE
			constant: CONSTANT
		do
			!!close; !!low; !!high
			!!constant.make (100) -- factor for conversion to percentage
			!!highest.make (f.output, high, n)
			!!lowest.make (f.output, low, n)
			!!s1.make (highest, close)
			!!s2.make (highest, lowest)
			!!d.make (s1, s2)
			!!m.make (d, constant)
			!!Result.make (f, m, n)
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
			m: MULTIPLICATION -- Used to convert value to percent.
			s1: SUBTRACTION
			s2: SUBTRACTION
			highest: HIGHEST_VALUE
			lowest: LOWEST_VALUE
			high: HIGH_PRICE
			low: LOW_PRICE
			close: CLOSING_PRICE
			constant: CONSTANT
		do
			!!close; !!low; !!high
			!!constant.make (100) -- factor for conversion to percentage
			!!highest.make (f.output, high, n)
			!!lowest.make (f.output, low, n)
			!!s1.make (close, lowest);
			!!s2.make (highest, lowest)
			!!d.make (s1, s2)
			!!m.make (d, constant)
			!!Result.make (f, m, n)
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
			mult: MULTIPLICATION -- Used to convert value to percent.
			sub1: SUBTRACTION
			sub2: SUBTRACTION
			basic1: BASIC_LINEAR_COMMAND
			basic2: BASIC_LINEAR_COMMAND
			close_low_function: N_RECORD_ONE_VARIABLE_FUNCTION
			high_low_function: N_RECORD_ONE_VARIABLE_FUNCTION
			ma1, ma2: STANDARD_MOVING_AVERAGE
			cmd: BASIC_NUMERIC_COMMAND
			highest: HIGHEST_VALUE
			lowest: LOWEST_VALUE
			high: HIGH_PRICE
			low: LOW_PRICE
			close: CLOSING_PRICE
			constant: CONSTANT
		do
			!!cmd
			!!close; !!low; !!high
			!!constant.make (100) -- factor for conversion to percentage
			!!highest.make (f.output, high, inner_n)
			!!lowest.make (f.output, low, inner_n)
			!!sub1.make (close, lowest);
			!!sub2.make (highest, lowest)
			!!close_low_function.make (f, sub1, inner_n)
			!!high_low_function.make (f, sub2, inner_n)
			close_low_function.set_name ("Close minus lowest low")
			high_low_function.set_name ("Highest high minus lowest low")
			!!ma1.make (close_low_function, cmd, outer_n)
			!!ma2.make (high_low_function, cmd, outer_n)
			ma1.set_name ("Moving Average of close minus lowest low")
			ma2.set_name ("Moving Average of close minus highest high")
			!!basic1.make (ma1.output)
			!!basic2.make (ma2.output)
			!!div.make (basic1, basic2)
			!!mult.make (div, constant)
			!!Result.make (ma1, ma2, mult)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

invariant

	innermost_function_not_void: innermost_function /= Void

end -- FUNCTION_BUILDER
