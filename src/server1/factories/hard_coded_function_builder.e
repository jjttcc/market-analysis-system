indexing
	description:
		"Builder of a list of market functions"
	note:
		"Hard-coded for testing for now, but may evolve into a legitimate %
		%class"
	date: "$Date$";
	revision: "$Revision$"

class FUNCTION_BUILDER inherit

	FACTORY
		redefine
			product
		end

feature -- Access

	product: LIST [MARKET_FUNCTION]

	Simple_MA_n: INTEGER is 30
	Smaller_EMA_n: INTEGER is 12
	Larger_EMA_n: INTEGER is 26

feature -- Basic operations

	execute (f: MARKET_FUNCTION) is
		local
			l: LINKED_LIST [MARKET_FUNCTION]
			ema1, ema2: EXPONENTIAL_MOVING_AVERAGE
		do
			!!l.make
			l.extend (simple_ma (f, Simple_MA_n))
			ema1 := ema (f, Smaller_EMA_n)
			ema2 := ema (f, Larger_EMA_n)
			l.extend (ema1)
			l.extend (ema2)
			l.extend (macd_diff (ema1, ema2))
			product := l
		end

feature -- Status report

	arg_used: BOOLEAN is true

feature {NONE} -- Hard-coded market function building procedures

	simple_ma (f: MARKET_FUNCTION; n: INTEGER):
						STANDARD_MOVING_AVERAGE is
			-- Make a simple moving average function.
		local
			cmd: BASIC_NUMERIC_COMMAND
		do
			!!cmd
			!!Result.make (f, cmd, n)
			Result.set_name ("Simple Moving Average")
		end

	ema (f: MARKET_FUNCTION; n: INTEGER): EXPONENTIAL_MOVING_AVERAGE is
			-- Make an exponential moving average function for testing.
		local
			cmd: BASIC_NUMERIC_COMMAND
			e: MA_EXPONENTIAL
		do
			!!cmd
			!!e.make (1)
			!!Result.make (f, cmd, e, n)
			Result.set_name ("Exponential Moving Average")
		end

	macd_diff (f1, f2: EXPONENTIAL_MOVING_AVERAGE): MARKET_FUNCTION is
			-- Create an MACD difference using `f1' and `f2'.
		require
			not_void: f1 /= Void and f2 /= Void
			-- !!!Is this precondition reasonable?:
			o_not_void: f1.output /= Void and f2.output /= Void
		local
			sub: SUBTRACTION
			cmd1: BASIC_LINEAR_COMMAND
			cmd2: BASIC_LINEAR_COMMAND
		do
			!!cmd1.make (f1.output)
			!!cmd2.make (f2.output)
			!!sub.make_with_operands (cmd1, cmd2)
			!TWO_VARIABLE_FUNCTION!Result.make (f1, f2, sub)
			Result.set_name ("MACD difference")
		ensure
			not_void: Result /= Void
		end

end -- FUNCTION_BUILDER
