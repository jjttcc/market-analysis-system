indexing
	description:
		"Builder of a list of hard-coded market functions"
	note:
		"Hard-coded for testing for now, but may evolve into a legitimate %
		%class"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class HARD_CODED_FUNCTION_BUILDER inherit

	FACTORY
		redefine
			product
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

creation

	make

feature

	make is
		do
			create innermost_function.make ("dummy",
				period_types @ (period_type_names @ Daily), Void)
		ensure
			not_void: innermost_function /= Void
		end

feature -- Access

	product: LIST [MARKET_FUNCTION]

	innermost_function: STOCK
			-- Dummy for innermost function for complex functions

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

feature -- Basic operations

	execute is
		local
			l: LINKED_LIST [MARKET_FUNCTION]
			f: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]
			cf1, cf2: COMPLEX_FUNCTION
		do
			f := innermost_function
			create l.make
			l.extend (simple_ma (f, Simple_MA_n, "Simple Moving Average"))
			l.extend (ema (f, EMA_n, "Exponential Moving Average"))
			cf1 := ma_diff (ema (f, Smaller_MACD_EMA_n, "Short EMA"),
								ema (f, Larger_MACD_EMA_n, "Long EMA"),
								"MACD Difference")
			l.extend (cf1)
			cf2 := ema (l.last, MACD_Signal_Line_EMA_n,
						"MACD Signal Line (EMA of MACD Difference)")
			l.extend (cf2)
			l.extend (ma_diff (cf1, cf2, "MACD Histogram"))
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
			l.extend (market_data (f, "Market Data"))
			l.extend (market_function_line (f, "Line"))
			product := l
		end

feature {NONE} -- Hard-coded market function building procedures

	simple_ma (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
						STANDARD_MOVING_AVERAGE is
			-- Make a simple moving average function.
		local
			cmd: BASIC_NUMERIC_COMMAND
		do
			create cmd
			create Result.make (f, cmd, n)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

	ema (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
				EXPONENTIAL_MOVING_AVERAGE is
			-- Make an exponential moving average function for testing.
		local
			cmd: BASIC_NUMERIC_COMMAND
			exp: N_BASED_UNARY_OPERATOR
			div: DIVISION
			two, one: CONSTANT
			add: ADDITION
			n_cmd: N_VALUE_COMMAND
		do
			create two.make (2); create one.make (1)
			create n_cmd.make (n)
			create add.make (n_cmd, one)
			create div.make (two, add)
			create exp.make (div, n)
			create cmd
			create Result.make (f, cmd, exp, n)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.n = n and Result.name = name
		end

	ma_diff (f1, f2: COMPLEX_FUNCTION; name: STRING): TWO_VARIABLE_FUNCTION is
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
			create close
			create cmd1.make (f1.output)
			create cmd2.make (f2.output)
			create sub.make (cmd1, cmd2)
			create Result.make (f1, f2, sub)
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
			create close; create close_minus_n.make (f.output, close, n)
			if operator_type.is_equal ("SUBTRACTION") then
				create {SUBTRACTION} operator.make (close, close_minus_n)
			else
				check operator_type.is_equal ("DIVISION") end
				create {DIVISION} operator.make (close, close_minus_n)
			end
			create Result.make (f, operator, n)
			-- For momentum, effective_n needs to be 1 larger than n.
			Result.set_effective_offset (1)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.n = n and Result.name = name
		end

	rsi (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
				TWO_VARIABLE_FUNCTION is
			-- RSI:  100 - (100 / (1 + RS))
			-- RS:  (average n up closes ) / (average n down closes)
		local
			one, one_hundred: CONSTANT
			outer_div, inner_div, add, sub: BINARY_OPERATOR [REAL, REAL]
			positive_average, negative_average: BASIC_LINEAR_COMMAND
			pos_ema, neg_ema: EXPONENTIAL_MOVING_AVERAGE
		do
			create one.make (1); create one_hundred.make (100)
			pos_ema := rs_average (f, n, true)
			neg_ema := rs_average (f, n, false)
			create positive_average.make (pos_ema.output)
			create negative_average.make (neg_ema.output)
			create {DIVISION} inner_div.make (positive_average,
				negative_average)
			create {ADDITION} add.make (one, inner_div)
			create {DIVISION} outer_div.make (one_hundred, add)
			create {SUBTRACTION} sub.make (one_hundred, outer_div)
			create Result.make (pos_ema, neg_ema, sub)
			Result.set_name (name)
		end

	obsolete_rsi (f: MARKET_FUNCTION; n: INTEGER; name: STRING):
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
			exp: N_BASED_UNARY_OPERATOR
		do
			create close; create zero.make (0)
			create one_hundred.make (100); create one.make (1);
			create nvalue.make (n); create offset1.make (f.output, close);
			create offset2.make (f.output, close)
			offset2.set_offset (1)
			create lt_op.make (offset1, offset2)
			create upsub.make (offset2, offset1)
			create up_boolclient.make (lt_op, upsub, zero)
			create up_adder.make (f.output, up_boolclient, n)
			create up_closes.make (f.output, up_adder, n)
			create upavg.make (up_closes, nvalue)

			create gt_op.make (offset1, offset2)
			-- Notice that order of arguments is different from upsub.make:
			create downsub.make (offset1, offset2)
			create down_boolclient.make (gt_op, downsub, zero)
			create down_adder.make (f.output, down_boolclient, n)
			create down_closes.make (f.output, down_adder, n)
			create downavg.make (down_closes, nvalue)

			create rs_div.make (upavg, downavg) -- RS: up avg / down avg
			create one_plus_rs.make (rs_div, one) -- 1 + RS
			create maindiv.make (one_hundred, one_plus_rs) -- 100 / (1 + RS)
			create outer_sub.make (one_hundred, maindiv) -- 100 - (100/(1+RS))
			create Result.make (f, outer_sub, n)
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
			create close; create low; create high
			create constant.make (100) -- factor for conversion to percentage
			create highest.make (f.output, high, n)
			create lowest.make (f.output, low, n)
			create s1.make (highest, close)
			create s2.make (highest, lowest)
			create d.make (s1, s2)
			create m.make (d, constant)
			create Result.make (f, m, n)
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
			create close; create low; create high
			create constant.make (100) -- factor for conversion to percentage
			create highest.make (f.output, high, n)
			create lowest.make (f.output, low, n)
			create s1.make (close, lowest);
			create s2.make (highest, lowest)
			create d.make (s1, s2)
			create m.make (d, constant)
			create Result.make (f, m, n)
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
			create cmd
			create close; create low; create high
			create constant.make (100) -- factor for conversion to percentage
			create highest.make (f.output, high, inner_n)
			create lowest.make (f.output, low, inner_n)
			create sub1.make (close, lowest);
			create sub2.make (highest, lowest)
			create close_low_function.make (f, sub1, inner_n)
			create high_low_function.make (f, sub2, inner_n)
			close_low_function.set_name ("Close minus lowest low")
			high_low_function.set_name ("Highest high minus lowest low")
			create ma1.make (close_low_function, cmd, outer_n)
			create ma2.make (high_low_function, cmd, outer_n)
			ma1.set_name ("Moving Average of close minus lowest low")
			ma2.set_name ("Moving Average of highest high minus lowest low")
			create basic1.make (ma1.output)
			create basic2.make (ma2.output)
			create div.make (basic1, basic2)
			create mult.make (div, constant)
			create Result.make (ma1, ma2, mult)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

	market_data (f: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]; name: STRING):
						MARKET_DATA_FUNCTION is
			-- Make a function that simply gives the closing price of
			-- each tuple.
		do
			create Result.make (f)
			Result.set_name (name)
		ensure
			initialized: Result /= Void and Result.name = name
		end

	market_function_line (f: MARKET_FUNCTION; name: STRING):
				MARKET_FUNCTION_LINE is
			-- Dummy line
		local
			p1, p2: MARKET_POINT
			earlier, later: DATE_TIME
		do
			create earlier.make (1998, 1, 1, 0, 0, 0)
			create later.make (1998, 1, 23, 0, 0, 0)
			create p1.make
			p1.set_x_y_date (earlier.day, 1, earlier)
			create p2.make
			p2.set_x_y_date (later.day, 1, later)
			create Result.make_from_2_points (p1, p2, f)
			Result.set_name (name)
		end

	rs_average (f: MARKET_FUNCTION; n: INTEGER; positive: BOOLEAN):
				EXPONENTIAL_MOVING_AVERAGE is
			-- Positive (`positive') or negative (not `positive') average
			-- used in the quotient for RS for the RSI formula
		local
			one, zero: CONSTANT
			exp: N_BASED_UNARY_OPERATOR
			div, sub: BINARY_OPERATOR [REAL, REAL]
			main_op: BOOLEAN_NUMERIC_CLIENT
			n_cmd: N_VALUE_COMMAND
			relational_op: BINARY_OPERATOR [BOOLEAN, REAL]
			offset_minus_1, offset_0: SETTABLE_OFFSET_COMMAND
			close: CLOSING_PRICE
			fname: STRING
		do
			create one.make (1); create zero.make (0)
			create close
			create offset_minus_1.make (f.output, close)
			offset_minus_1.set_offset (-1)
			create offset_0.make (f.output, close)
			create n_cmd.make (n)
			create {DIVISION} div.make (one, n_cmd)
			create exp.make (div, n)
			if positive then
				-- Set up the bool operand for main_op so that the result
				-- is the current close minus the previous close if that
				-- is positive - otherwise, 0.
				fname := "Positive average for RSI"
				create {LT_OPERATOR} relational_op.make (offset_minus_1,
					offset_0)
				create {SUBTRACTION} sub.make (offset_0, offset_minus_1)
			else
				-- Set up the bool operand for main_op so that the result
				-- is the previous close minus the current close if that
				-- is positive - otherwise, 0.
				fname := "Negative average for RSI"
				create {GT_OPERATOR} relational_op.make (offset_minus_1,
					offset_0)
				create {SUBTRACTION} sub.make (offset_minus_1, offset_0)
			end
			create main_op.make (relational_op, sub, zero)
			create Result.make (f, main_op, exp, n)
			Result.set_name (fname)
			-- Because a SETTABLE_OFFSET_COMMAND with an offset of -1 is
			-- one of the operators used (indirectly) by Result, the
			-- effective offset must be set to the opposite value (1) to
			-- compensate - ensure that the left-most element of the input
			-- being processed is the first element.
			Result.set_effective_offset (1)
		end

invariant

	innermost_function_not_void: innermost_function /= Void

end -- HARD_CODED_FUNCTION_BUILDER
