indexing
	description:
		"A function that outputs an array of market tuples.  Specifications %
		%for function input are provided by descendant classes."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_FUNCTION inherit

	FACTORY
		rename
			product as output, execute as process
		redefine
			output
		end

feature -- Access

	name: STRING
			-- Function name

	short_description: STRING is
			-- Short description of the function
		deferred
		end

	full_description: STRING is
			-- Full description of the function, including descriptions
			-- of contained functions, if any
		deferred
		end

	output: MARKET_TUPLE_LIST [MARKET_TUPLE] is
			-- y of function "y = f(x)"
		deferred
		end

	trading_period_type: TIME_PERIOD_TYPE is
			-- Type of trading period associated with each tuple:  hourly,
			-- daily, weekly, etc.
		deferred
		end

	parameters: LIST [FUNCTION_PARAMETER] is
			-- Changeable parameters for this function
		deferred
		end

	processed_date_time: DATE_TIME is
			-- Date and time the function was last processed
		deferred
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		deferred
		end

feature -- Basic operations

	process is
			-- Process the output from the input.
		deferred
		ensure then
			processed: processed
		end

feature {FACTORY, MARKET_FUNCTION_EDITOR} -- Status setting

	set_name (n: STRING) is
			-- Set the function's name to n.
		require
			not_void: n /= Void
		do
			name := n
		ensure
			is_set: name = n and name /= Void
		end

	set_innermost_input (in: SIMPLE_FUNCTION [MARKET_TUPLE]) is
			-- If the run-time type is a complex function, set the innermost
			-- input attribute to `in', else do nothing.
		require
			not_void: in /= Void
		do
		end

feature {MARKET_FUNCTION}

	is_complex: BOOLEAN is
			-- Is the run-time type a complex function?
		deferred
		end

invariant

	output_not_void: output /= Void
	trading_period_type_not_void: trading_period_type /= Void
	parameters_not_void: parameters /= Void
	date_time_not_void_when_processed:
		processed implies processed_date_time /= Void

end -- class MARKET_FUNCTION
