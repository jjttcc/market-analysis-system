indexing
	description: "A linear command that gets its input from a MARKET_FUNCTION"
	note: "This class is used only by ONE_VARIABLE_FUNCTION_ANALYZER."
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class FUNCTION_BASED_COMMAND inherit

	UNARY_LINEAR_OPERATOR
		rename
			make as ulo_make_unused
		export
			{NONE} ulo_make_unused
		undefine
			start
		redefine
			initialize, execute, target_cursor_not_affected
		end
	
	ONE_VARIABLE_LINEAR_ANALYZER

	MARKET_FUNCTION_EDITOR

creation

	make

feature {NONE} -- Initialization

	make (in: like input; op: like operand) is
		--require
		--	not_void: input /= Void and op /= Void
		do
			input := in
			set_target (input.output)
			set_operand (op)
		ensure
			set: input = in and operand = op
		end

feature -- Initialization

	initialize (a: ONE_VARIABLE_FUNCTION_ANALYZER) is
		do
			start_date_time := a.start_date_time
			left_offset := a.left_offset
			input.set_innermost_input (a.tradable)
			if not input.processed then
				input.process
			end
			-- Advance target cursor according to start_date_time and
			-- left_offset.
			start
			operand.initialize (Current)
		ensure then
			input_processed: input.processed
			date_not_earlier: not target.exhausted implies
							target.item.date_time >= start_date_time
			offset_constraint:
				not target.exhausted implies target.index >= left_offset
		end

feature -- Access

	input: MARKET_FUNCTION

	 start_date_time: DATE_TIME

feature -- Status report

	target_cursor_not_affected: BOOLEAN

feature -- Status setting

	set_input (arg: like input) is
			-- Set input to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input := arg
			set_target (input.output)
		ensure
			input_set: input = arg and input /= Void
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			-- The client of this class has no control over the linear
			-- structure `target', so responsibility must be taken for
			-- not incrementing beyond the end of `target'.
			if not target.off then
				operand.execute (target.item)
				value := operand.value
				target.forth
				target_cursor_not_affected := false
			else
				target_cursor_not_affected := true
			end
		end

invariant

	target_is_output: target = input.output

end -- class FUNCTION_BASED_COMMAND
