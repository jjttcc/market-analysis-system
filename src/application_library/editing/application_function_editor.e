indexing
	description:
		"Editor of MARKET_FUNCTIONs to be used in a TAL application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class APPLICATION_FUNCTION_EDITOR inherit

	MARKET_FUNCTION_EDITOR
		export
			{NONE} all
		end

	APPLICATION_EDITOR
		redefine
			user_interface
		end

	GLOBAL_SERVICES

feature -- Access

	user_interface: FUNCTION_EDITING_INTERFACE
			-- Interface used to obtain data selections from user

feature -- Basic operations

	edit_binary_boolean (cmd: BINARY_OPERATOR [ANY, BOOLEAN]) is
			-- Edit a BINARY_OPERATOR that takes BOOLEAN operands.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [BOOLEAN]
		do
			left ?= user_interface.function_selection (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s left operand">>), false)
			right ?= user_interface.function_selection (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s right operand">>), false)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_mtlist_resultreal_n (f: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit `f's market tuple list, operator (
			-- RESULT_COMMAND [REAL]), and n-value.
		require
			ui_set: user_interface /= Void
		local
			offset_cmd: LINEAR_OFFSET_COMMAND
		do
			edit_n (f)
			edit_mtlist (f)
			edit_unaryop (f)
			offset_cmd ?= f
			if offset_cmd /= Void then
				record_lowest_offset (offset_cmd)
			end
		end

	edit_n (f: MARKET_FUNCTION) is
			-- Edit `f's n-value.
		require
			ui_set: user_interface /= Void
		local
			cmd: N_RECORD_COMMAND
		do
			cmd ?= f
			check
				c_is_valid_type: cmd /= Void
			end
			cmd.set_n (user_interface.integer_selection (
						concatenation (<<cmd.generator, "'s n-value">>)))
		end

	edit_mtlist (f: MARKET_FUNCTION) is
			-- Edit `f's market tuple list target.
		require
			ui_set: user_interface /= Void
		local
			cmd: LINEAR_COMMAND
		do
			cmd ?= f
			check
				c_is_valid_type: cmd /= Void
			end
			cmd.set_target (user_interface.market_tuple_list_selection (
								cmd.generator))
		end

	edit_offset (cmd: SETTABLE_OFFSET_COMMAND) is
			-- Edit a SETTABLE_OFFSET_COMMAND.
		local
			unop: UNARY_OPERATOR [ANY, REAL]
			offset: INTEGER
		do
			unop ?= cmd
			check
				cmd_is_a_unop_real: unop /= Void
			end
			edit_unaryop (unop)
			edit_mtlist (cmd)
			from
				offset := user_interface.integer_selection (
						concatenation (<<cmd.generator,
						"'s (left) offset value (must be non-negative)">>))
			until
				offset >= 0
			loop
				user_interface.show_message ("Negative value entered.")
				offset := user_interface.integer_selection (
						concatenation (<<cmd.generator,
						"'s (left) offset value (must be non-negative)">>))
			end
			cmd.set_offset (-offset)
			record_lowest_offset (cmd)
		end

	record_lowest_offset (cmd: LINEAR_OFFSET_COMMAND) is
			-- If `cmd's offset value (expected to be negative or 0) is
			-- lower than the current offset value, record the offset
			-- value so that the lowest (or highest-magnitude) value can
			-- be used to keep objects needing it consistent.
		do
			-- Important: The arithmetic negation of the `cmd.offset'
			-- (which is expected to be negative) is used - the
			-- `left_offset' value being set must be positive.
			if -cmd.offset > user_interface.left_offset then
				user_interface.set_left_offset (-cmd.offset)
			end
		end

end -- APPLICATION_FUNCTION_EDITOR
