note
	description: "A linear command that gets its input from a MARKET_FUNCTION"
	note1: "@@This class has recently been modified to be used for indicators %
		%in addition to its original use by ONE_VARIABLE_FUNCTION_ANALYZER.%
		%Although this new functionality has been tested successfully, it %
		%has not yet been tested thoroughly."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class FUNCTION_BASED_COMMAND inherit

	UNARY_LINEAR_OPERATOR
		rename
			make as ulo_make_unused
		export
			{NONE} ulo_make_unused
		undefine
			start
		redefine
			initialize, execute, target_cursor_not_affected,
			prepare_for_editing, is_editable
		end
	
	ONE_VARIABLE_LINEAR_ANALYZER

	MARKET_FUNCTION_EDITOR

creation

	make

feature {NONE} -- Initialization

	make (in: like input; op: like operand)
		require
			not_void: in /= Void and op /= Void
		do
			input := in
			set (input.output)
			set_operand (op)
		ensure
			set: input = in and operand = op
		end

feature -- Initialization

	initialize (a: LINEAR_ANALYZER)
		local
			analyzer: ONE_VARIABLE_FUNCTION_ANALYZER
			function: MARKET_FUNCTION
		do
			analyzer ?= a
			if analyzer /= Void then
				start_date_time := analyzer.start_date_time
				left_offset := analyzer.left_offset
				innermost_input := analyzer.current_tradable
			else
				function ?= a
				check
					arg_is_a_function: function /= Void
				end
				if function.innermost_input.count > 0 then
					start_date_time :=
						function.innermost_input.first.date_time
				end
				left_offset := 0
				innermost_input := function.innermost_input
				function_based := True
			end
			input.set_innermost_input (innermost_input)
			if not input.processed then
				input.process
			end
			-- Advance target cursor according to start_date_time and
			-- left_offset.
			start
			operand.initialize (Current)
			if
				function /= Void and then
				not target.is_empty and then
				start_date_time < target.item.date_time
			then
				-- Ensure the postcondition when `a' is a MARKET_FUNCTION.
				start_date_time := target.item.date_time
			end
		ensure then
			input_processed: input.processed
			date_not_earlier: not target.exhausted implies
							target.item.date_time >= start_date_time
			offset_constraint:
				not target.exhausted implies target.index >= left_offset
			innermost_input_exists: input.processed implies
				innermost_input /= Void
		end

feature -- Access

	input: MARKET_FUNCTION

	 start_date_time: DATE_TIME

feature -- Status report

	target_cursor_not_affected: BOOLEAN

	is_editable: BOOLEAN
		note
			once_status: global
		once
			Result := True
		end

feature -- Status setting

	set_input (arg: like input)
			-- Set input to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input := arg
			set (input.output)
		ensure
			input_set: input = arg and input /= Void
		end

feature -- Basic operations

	execute (arg: ANY)
		do
			if function_based then
				synchronize_target_with_innermost_input
			end
			-- The client of this class may have no control over the linear
			-- structure `target', so responsibility must be taken for
			-- not incrementing beyond the end of `target'.
			if not target.off then
				check
					dates_match: target.item.date_time.is_equal (
						input.innermost_input.item.date_time)
				end
				operand.execute (target.item)
				value := operand.value
				if not function_based then
					target.forth
				end
				target_cursor_not_affected := False
			else
				target_cursor_not_affected := not function_based
			end
		end

	prepare_for_editing (l: LIST [FUNCTION_PARAMETER])
		do
			input.parameters.do_all (agent l.extend)
		end

feature {NONE} -- Implementation

	function_based: BOOLEAN
			-- Is the input based on a MARKET_FUNCTION (as opposed to a
			-- ONE_VARIABLE_FUNCTION_ANALYZER?

	innermost_input: SIMPLE_FUNCTION [MARKET_TUPLE]
			-- Innermost input sequence of `input' - used for efficiency

	synchronize_target_with_innermost_input
			-- Synchronize `target' with `innermost_input'.
		require
			innermost_input_not_off: not innermost_input.off
		do
			if target.off then
				target.start
			end
			if
				not target.off and then target.item.date_time <
				innermost_input.item.date_time
			then
				from
				until
					target.exhausted or target.item.date_time.is_equal (
						innermost_input.item.date_time)
				loop
					target.forth
				end
			elseif
				not target.off and then target.item.date_time >
				innermost_input.item.date_time
			then
				from
				until
					target.exhausted or target.item.date_time.is_equal (
						innermost_input.item.date_time)
				loop
					target.back
				end
			end
		ensure
			dates_equal_if_not_off: not target.exhausted implies
				target.item.date_time.is_equal (innermost_input.item.date_time)
		end

invariant

	target_is_output: target = input.output

end -- class FUNCTION_BASED_COMMAND
