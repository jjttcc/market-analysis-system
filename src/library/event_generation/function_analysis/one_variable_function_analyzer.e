indexing
	description:
		"Market analyzer that analyzes one market function"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ONE_VARIABLE_MARKET_ANALYZER inherit

	MARKET_ANALYZER

	LINEAR_ANALYZER
		redefine
			start, action
		end

creation

	make

feature -- Initialization

	make (in: like input; op: BOOLEAN_OPERATOR; start_date: DATE_TIME) is
		require
			not_void: in /= Void and op /= Void and start_date /= Void
		do
			set_input (in)
			start_date_time := start_date
			operator := op
		ensure
			set: input = in and operator = op and start_date_time = start_date
		end

feature -- Access

	input: MARKET_FUNCTION

feature -- Status setting

	set_innermost_function (f: SIMPLE_FUNCTION [MARKET_TUPLE]) is
			-- Set the innermost function, which contains the basic
			-- data to be analyzed.
		do
			input.set_innermost_input (f)
		end

	set_input (in: like input) is
		require
			in_not_void: in /= Void and in.output /= Void
			output_not_void: output /= Void
		do
			input := in
			set_target (input.output)
		ensure
			input_set_to_in: input = in
		end

feature {NONE} -- Hook routine implementation

	start is
		do
			from
				target.start
			until
				target.date_time.is_equal (start_date_time)
			loop
				target.forth
			end
		ensure then
			dates_equal: target.date_time.is_equal (start_date_time)
		end

	action is
		do
			operator.execute
			if operator.value then
				generate_event
			end
		end

end -- class ONE_VARIABLE_MARKET_ANALYZER
