indexing
	description:
		"A function that outputs an array of market tuples.  Specifications %
		%for function input are provided by descendant classes."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
			-- Changeable parameters for this function, including those
			-- of `children'
		deferred
		end

	immediate_parameters: LIST [FUNCTION_PARAMETER] is
			-- Changeable parameters for this function without those
			-- of `children'
		deferred
		end

	processed_date_time: DATE_TIME is
			-- Date and time the function was last processed
		deferred
		end

	children: LIST [MARKET_FUNCTION] is
			-- This function's children, if it is a composite function
		deferred
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		deferred
		end

	has_children: BOOLEAN is
			-- Does this function have children?
		deferred
		ensure
			Result implies children /= Void and not children.empty
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
			not_void: in /= Void and in.trading_period_type /= Void
		do
		ensure
			output_empty_if_complex_and_not_processed:
				is_complex and not processed implies output.empty
		end

feature {MARKET_FUNCTION}

	is_complex: BOOLEAN is
			-- Is the run-time type a complex function?
		deferred
		end

invariant

	output_not_void: output /= Void
	parameters_not_void: parameters /= Void and immediate_parameters /= Void
	date_time_not_void_when_processed:
		processed implies processed_date_time /= Void

end -- class MARKET_FUNCTION
