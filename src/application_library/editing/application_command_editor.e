indexing
	description:
		"Editor of COMMANDs to be used in a MAL application"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class APPLICATION_COMMAND_EDITOR inherit

	COMMAND_EDITOR
		export
			{NONE} all
		end

	APPLICATION_EDITOR
		redefine
			user_interface
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (ui: COMMAND_EDITING_INTERFACE) is
		require
			not_void: ui /= Void
		do
			user_interface := ui
		ensure
			set: user_interface = ui
		end

feature -- Access

	user_interface: COMMAND_EDITING_INTERFACE
			-- Interface used to obtain data selections from user

feature -- Basic operations

	edit_binary_boolean (cmd: BINARY_OPERATOR [ANY, BOOLEAN]) is
			-- Edit a BINARY_OPERATOR that takes BOOLEAN operands.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [BOOLEAN]
		do
			left ?= user_interface.command_selection_from_type (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s left operand">>), false)
			right ?= user_interface.command_selection_from_type (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s right operand">>), false)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_binary_real (cmd: BINARY_OPERATOR [ANY, REAL]) is
			-- Edit a BINARY_OPERATOR that takes REAL operands.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [REAL]
		do
			left ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s left operand">>), false)
			right ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s right operand">>), false)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_mtlist_resultreal (c: UNARY_OPERATOR [REAL, REAL]) is
			-- Edit `c's market tuple list and operator
			-- (RESULT_COMMAND [REAL]).
		require
			ui_set: user_interface /= Void
		do
			edit_mtlist (c)
			edit_unaryop_real (c)
		end

	edit_mtlist_resultreal_n (c: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit `c's market tuple list, operator (
			-- RESULT_COMMAND [REAL]), and n-value.
		require
			ui_set: user_interface /= Void
		local
			offset_cmd: LINEAR_OFFSET_COMMAND
		do
			edit_n (c)
			edit_mtlist (c)
			edit_unaryop (c)
			offset_cmd ?= c
			if offset_cmd /= Void then
				record_lowest_offset (offset_cmd)
			end
		end

	edit_resultreal_n (c: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit `c's operator (RESULT_COMMAND [REAL]), and n-value.
		require
			ui_set: user_interface /= Void
		do
			edit_n (c)
			edit_unaryop (c)
		end

	edit_n (c: COMMAND) is
			-- Edit `c's n-value.
		require
			ui_set: user_interface /= Void
		local
			cmd: N_RECORD_COMMAND
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			cmd.set_n (user_interface.integer_selection (
						concatenation (<<cmd.generator, "'s n-value">>)))
		end

	edit_mtlist (c: COMMAND) is
			-- Edit `c's market tuple list target.
		require
			ui_set: user_interface /= Void
		local
			cmd: LINEAR_COMMAND
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			user_interface.set_use_market_function_selection (false)
			cmd.set_target (user_interface.market_function_selection (
				concatenation (<<"an indicator for ", cmd.generator,
								"'s input">>)).output)
		end

	edit_unaryop (cmd: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit a UNARY_OPERATOR that takes a RESULT_COMMAND [REAL]
			-- operand.
		require
			ui_set: user_interface /= Void
		local
			hv: HIGHEST_VALUE
			lv: LOWEST_VALUE
			rr_cmd: RESULT_COMMAND [REAL]
			bnc_cmd: BASIC_NUMERIC_COMMAND
		do
			hv ?= cmd
			lv ?= cmd
			-- If cmd conforms to HIGHEST_VALUE or LOWEST_VALUE, it
			-- needs an operand of type BASIC_NUMERIC_COMMAND.
			if hv /= Void then
				bnc_cmd ?= user_interface.command_selection_from_type (
							user_interface.Basic_numeric_command,
							concatenation (<<cmd.generator, "'s operand">>),
							false)
				check
					selection_valid: bnc_cmd /= Void
				end
				hv.set_operand (bnc_cmd)
			elseif lv /= Void then
				bnc_cmd ?= user_interface.command_selection_from_type (
							user_interface.Basic_numeric_command,
							concatenation (<<cmd.generator, "'s operand">>),
							false)
				check
					selection_valid: bnc_cmd /= Void
				end
				lv.set_operand (bnc_cmd)
			else
				rr_cmd ?= user_interface.command_selection_from_type (
							user_interface.Real_result_command,
							concatenation (<<cmd.generator, "'s operand">>),
							false)
				check
					selection_valid: rr_cmd /= Void
				end
				cmd.set_operand (rr_cmd)
			end
		end

	edit_unaryop_real (cmd: UNARY_OPERATOR [REAL, REAL]) is
			-- Edit a UNARY_OPERATOR that returns a REAL value and
			-- takes a RESULT_COMMAND [REAL] operand.
		require
			ui_set: user_interface /= Void
		local
			rr_cmd: RESULT_COMMAND [REAL]
		do
			rr_cmd ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
						concatenation (<<cmd.generator, "'s operand">>),
						false)
			check
				selection_valid: rr_cmd /= Void
			end
			cmd.set_operand (rr_cmd)
		end

	edit_unary_boolean (cmd: UNARY_OPERATOR [BOOLEAN, BOOLEAN]) is
			-- Edit a UNARY_OPERATOR that returns a BOOLEAN value and
			-- takes a RESULT_COMMAND [BOOLEAN] operand.
		require
			ui_set: user_interface /= Void
		local
			bool_cmd: RESULT_COMMAND [BOOLEAN]
		do
			bool_cmd ?= user_interface.command_selection_from_type (
						user_interface.Boolean_result_command,
						concatenation (<<cmd.generator, "'s operand">>),
						false)
			check
				selection_valid: bool_cmd /= Void
			end
			cmd.set_operand (bool_cmd)
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

	edit_boolean_numeric_client (cmd: BOOLEAN_NUMERIC_CLIENT) is
			-- Edit a BOOLEAN_NUMERIC_CLIENT.
		local
			binop: BINARY_OPERATOR [BOOLEAN, REAL]
			result_cmd: RESULT_COMMAND [REAL]
		do
			-- Obtain and set cmd's boolean operator.
			binop ?= user_interface.command_selection_from_type (
						user_interface.Binary_boolean_real_command,
							concatenation (<<cmd.generator,
								"'s boolean operator">>), false)
			check
				selection_valid: binop /= Void
			end
			cmd.set_boolean_operator (binop)
			-- Obtain and set cmd's true command.
			result_cmd ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s true command">>), false)
			check
				selection_valid: result_cmd /= Void
			end
			cmd.set_true_cmd (result_cmd)
			-- Obtain and set cmd's false command.
			result_cmd ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s false command">>), false)
			check
				selection_valid: result_cmd /= Void
			end
			cmd.set_false_cmd (result_cmd)
		end

	edit_sign_analyzer (cmd: SIGN_ANALYZER) is
			-- Edit a SIGN_ANALYZER.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [REAL]
			sign_spec: ARRAY [INTEGER]
			sign_spec_vector: ARRAY [ARRAY [INTEGER]]
			choices: LIST [PAIR [STRING, BOOLEAN]]
			pair: PAIR [STRING, BOOLEAN]
		do
			!!sign_spec_vector.make (1, 6)
			sign_spec_vector.put (<<-1, 1>>, 1)
			sign_spec_vector.put (<<1, -1>>, 2)
			sign_spec_vector.put (<<-1, 0>>, 3)
			sign_spec_vector.put (<<1, 0>>, 4)
			sign_spec_vector.put (<<0, -1>>, 5)
			sign_spec_vector.put (<<0, 1>>, 6)
			left ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
								concatenation (<<cmd.generator,
									"'s left operand">>), false)
			right ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
								concatenation (<<cmd.generator,
									"'s right operand">>), false)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
			!LINKED_LIST [PAIR [STRING, BOOLEAN]]!choices.make
			!!pair.make ("negative to positive", false)
			choices.extend (pair)
			!!pair.make ("positive to negative", false)
			choices.extend (pair)
			!!pair.make ("negative to zero", false)
			choices.extend (pair)
			!!pair.make ("positive to zero", false)
			choices.extend (pair)
			!!pair.make ("zero to negative", false)
			choices.extend (pair)
			!!pair.make ("zero to positive", false)
			choices.extend (pair)
			user_interface.choice (concatenation (<<"slope specification for ",
				cmd.generator>>), choices, choices.count)
			from
				choices.start
			until
				choices.exhausted
			loop
				if choices.item.right then
					cmd.add_sign_change_spec (sign_spec_vector @ choices.index)
				end
				choices.forth
			end
			debug
				print ("sign analyzer's sign spec:%N")
				from
					cmd.sign_change_spec.start
				until
					cmd.sign_change_spec.exhausted
				loop
					print (cmd.sign_change_spec.item)
					print ("%N")
					cmd.sign_change_spec.forth
				end
			end
		end

	edit_constant (cmd: CONSTANT) is
			-- Edit a simple command that takes a REAL value
			-- (such as CONSTANT).
		require
			ui_set: user_interface /= Void
		local
			x: REAL
		do
			cmd.set_constant_value (user_interface.real_selection (
								concatenation (<<cmd.generator, "'s value">>)))
		end

	edit_function_based_command (cmd: FUNCTION_BASED_COMMAND) is
			-- Edit a FUNCTION_BASED_COMMAND.
		do
			-- Always allow the user to select a FUNCTION_BASED_COMMAND's
			-- market function.
			user_interface.set_use_market_function_selection (true)
			cmd.set_input (user_interface.market_function_selection (
				concatenation (<<"an indicator for ", cmd.generator,
								"'s input">>)))
			edit_unaryop_real (cmd)
		end

end -- APPLICATION_COMMAND_EDITOR
