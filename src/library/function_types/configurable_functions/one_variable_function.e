indexing
	description:
		"A market function that takes one argument or variable"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class ONE_VARIABLE_FUNCTION inherit

	COMPLEX_FUNCTION
		redefine
			set_innermost_input, reset_parameters
		end

	SETTABLE_LINEAR_ANALYZER
		export {NONE}
			set
		redefine
			action, start
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (in: like input; op: like operator) is
		require
			in_not_void: in /= Void
			op_not_void_if_used: operator_used implies op /= Void
			in_output_not_void: in.output /= Void
			in_ptype_not_void: in.trading_period_type /= Void
		do
			set_input (in)
			if op /= Void then
				set_operator (op)
				operator.initialize (Current)
			end
			check
				target_not_void: target /= Void
				-- make_output uses target.
			end
			make_output
		ensure
			set: input = in and operator = op
		end

feature -- Access

	trading_period_type: TIME_PERIOD_TYPE is
		do
			Result := input.trading_period_type
		ensure then
			Result = input.trading_period_type
		end

	short_description: STRING is
		once
			Result := "Indicator that operates on a data sequence"
		end

	full_description: STRING is
		do
			create Result.make (25)
			Result.append (short_description)
			Result.append (":%N")
			Result.append (input.full_description)
		end

	children: LIST [MARKET_FUNCTION] is
		do
			create {LINKED_LIST [MARKET_FUNCTION]} Result.make
			Result.extend (input)
		end

	leaf_functions: LIST [COMPLEX_FUNCTION] is
		local
			f: COMPLEX_FUNCTION
		do
			create {LINKED_LIST [COMPLEX_FUNCTION]} Result.make
			if input.is_complex then
				f ?= input
				Result.append (f.leaf_functions)
			else
				Result.extend (Current)
			end
		end

	innermost_input: SIMPLE_FUNCTION [MARKET_TUPLE] is
		do
			if input.is_complex then
				Result := input.innermost_input
			else
				Result ?= input
			end
		ensure then
			exists: Result /= Void
		end

feature {FACTORY} -- Element change

	set_innermost_input (in: SIMPLE_FUNCTION [MARKET_TUPLE]) is
		do
			processed_date_time := Void
			if input.is_complex then
				input.set_innermost_input (in)
			else
				set_input (in)
				-- Allow all linear commands in the operator hierarchy to
				-- update their targets with the new `input' object.
				-- It's only when 'not input.is_complex' that this needs to
				-- be done (that is, Current is a complex leaf function) -
				-- the linear operators of non-leaf functions need to keep
				-- their existing targets, which are the `output's of
				-- complex functions, to maintain the functions semantics.
				initialize_operators
			end
			output.wipe_out
		end

feature -- Status report

	processed: BOOLEAN is
		do
			Result := input.processed and then
						processed_date_time /= Void and then
						processed_date_time >= input.processed_date_time
		end

	has_children: BOOLEAN is True

feature {NONE}

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (target.item)
			create t.make (target.item.date_time, target.item.end_date,
						operator.value)
			output.extend (t)
			if debugging then
				print_status_report
			end
		ensure then
			one_more_in_output: output.count = old output.count + 1
			date_time_correspondence:
				output.last.date_time.is_equal (target.item.date_time)
		end

	start is
		do
			Precursor
		end

	do_process is
			-- Execute the function.
		do
			do_all
		end

	pre_process is
		do
			if not output.is_empty then
				output.wipe_out
			end
			if not input.processed then
				input.process
			end
		ensure then
			input_processed: input.processed
		end

feature {MARKET_FUNCTION_EDITOR}

	set_input (in: like input) is
		require
			in_not_void: in /= Void and in.output /= Void
			ptype_not_void: in.trading_period_type /= Void
		do
			input := in
			set (input.output)
			processed_date_time := Void
		ensure
			input_set_to_in: input = in
			not_processed: not processed
		end

	reset_parameters is
		do
			input.reset_parameters
		end

feature {MARKET_FUNCTION_EDITOR}

	input: MARKET_FUNCTION

feature {NONE} -- Implementation

	make_output is
		do
			create output.make (target.count)
		end

	initialize_operators is
			-- Initialize all operators that are not Void - default:
			-- initialize `operator' if it's not Void.
		do
			if operator /= Void then
				-- operator will set its target to new input.output.
				operator.initialize (Current)
			end
		end

invariant

	processed_constraint: processed implies input.processed
	input_not_void: input /= Void
	input_target_relation: input.output = target
	has_one_child: has_children and children.count = 1

end -- class ONE_VARIABLE_FUNCTION
