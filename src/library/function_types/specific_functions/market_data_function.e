indexing
	description: 
		"A complex function whose input consists of market data and whose %
		%output is simply its input"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_DATA_FUNCTION inherit

	COMPLEX_FUNCTION
		redefine
			set_innermost_input, output, operator_used, process
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Access

	output: like input

	trading_period_type: TIME_PERIOD_TYPE is
		do
			Result := input.trading_period_type
		ensure then
			Result = input.trading_period_type
		end

	short_description: STRING is
		once
			Result := "Indicator whose input is basic market data and %
				%whose output is simply its input"
		end

	full_description: STRING is
		do
			!!Result.make (65)
			Result.append (short_description)
			Result.append (":%N")
			Result.append (input.full_description)
		end

	parameters: LIST [FUNCTION_PARAMETER] is
			-- Empty list - no parameters
		once
			!LINKED_LIST [FUNCTION_PARAMETER]!Result.make
		end

feature -- Status report

	processed: BOOLEAN is
		do
			Result := true
		end

	operator_used: BOOLEAN is false

feature -- Basic operations

	process is do end

feature {NONE} -- Inapplicable

	do_process is do end

	pre_process is do end

feature {MARKET_FUNCTION_EDITOR}

	set_input, make, set_innermost_input (in: like input) is
		require else
			in_not_void: in /= Void
		do
			input := in
			output := input
			processed_date_time := input.processed_date_time
		ensure then
			input_set_to_in: input = in
			output_is_input: output = input
			processed_date_time_not_void: processed_date_time /= Void
		end

feature {MARKET_FUNCTION_EDITOR}

	input: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]

invariant

	always_processed: processed and input.processed
	input_not_void: input /= Void
	output_is_input: output = input

end -- class MARKET_DATA_FUNCTION
