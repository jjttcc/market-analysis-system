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

	operator: NUMERIC_COMMAND
			-- Operator that will perform the main work of the function.
			-- Descendant classes may choose not to use this attribute for
			-- efficiency.

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

	operator_used: BOOLEAN is
			-- Is operator used by this function?
		deferred
		end

	processed: BOOLEAN is
			-- Has this function been processed?
		deferred
		end

feature -- Basic operations

	process is
			-- Process the output from the input.
		do
			if not processed then
				pre_process
				do_process
				update_processed_date_time
			end
			debug
				print (name); print (" just became processed, output size: ")
				print (output.count); print ("%N")
			end
		ensure then
			processed: processed
		end

feature {FACTORY} -- Status setting

	set_operator (op: NUMERIC_COMMAND) is
		require
			not_void: op /= Void
		do
			operator := op
		ensure
			op_set: operator = op and operator /= Void
		end

	set_name (n: STRING) is
			-- Set the function's name to n.
		require
			not_void: n /= Void
		do
			name := n
		ensure
			is_set: name = n and name /= Void
		end

feature {NONE} -- Hook methods

	pre_process is
			-- Do any pre-processing required before calling do_process.
		require
			not_processed: not processed
		do
		ensure
			output_empty: output.empty
		end

	do_process is
			-- Do the actual processing.
			-- Hook method to be defined by descendants
		require
			output_empty: output.empty
		deferred
		end

	update_processed_date_time is
			-- Set processed_date_time to now.
			-- Defaults to null action.
		do
		end

invariant

	output_not_void: output /= Void
	op_used_constraint: operator_used implies operator /= Void
	trading_period_type_not_void: trading_period_type /= Void
	parameters_not_void: parameters /= Void
	date_time_not_void_when_processed:
		processed implies processed_date_time /= Void

end -- class MARKET_FUNCTION
