indexing
	description:
		"Editor of COMMANDs to be used in a TAL application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class APPLICATION_COMMAND_EDITOR inherit

	COMMAND_EDITOR
		export
			{NONE} all
		end

	GLOBAL_SERVICES

feature -- Access

	user_interface: COMMAND_EDITING_INTERFACE
			-- Interface used to obtain data selections from user

feature -- Status setting

	set_user_interface (arg: COMMAND_EDITING_INTERFACE) is
			-- Set user_interface to `arg'.
		require
			arg_not_void: arg /= Void
		do
			user_interface := arg
		ensure
			user_interface_set: user_interface = arg and
				user_interface /= Void
		end

feature -- Basic operations

	edit_binary_boolean (cmd: BINARY_OPERATOR [ANY, BOOLEAN]) is
			-- Edit a BINARY_OPERATOR that takes BOOLEAN operands.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [BOOLEAN]
		do
			left ?= user_interface.command_selection (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s left operand">>), false)
			right ?= user_interface.command_selection (
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
			left ?= user_interface.command_selection (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s left operand">>), false)
			right ?= user_interface.command_selection (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s right operand">>), false)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_mtlist_resultreal_n (c: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit `c's market tuple list, operator (
			-- RESULT_COMMAND [REAL]), and n-value.
		require
			ui_set: user_interface /= Void
		do
			edit_n (c)
			edit_mtlist (c)
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
			cmd.set_target (user_interface.market_tuple_list_selection (
								cmd.generator))
		end

	edit_unaryop (cmd: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit a UNARY_OPERATOR that takes a REAL operand.
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
				bnc_cmd ?= user_interface.command_selection (
							user_interface.Basic_numeric_command,
							concatenation (<<cmd.generator, "'s operand">>),
							false)
				check
					selection_valid: bnc_cmd /= Void
				end
				hv.set_operand (bnc_cmd)
			elseif lv /= Void then
				bnc_cmd ?= user_interface.command_selection (
							user_interface.Basic_numeric_command,
							concatenation (<<cmd.generator, "'s operand">>),
							false)
				check
					selection_valid: bnc_cmd /= Void
				end
				lv.set_operand (bnc_cmd)
			else
				rr_cmd ?= user_interface.command_selection (
							user_interface.Real_result_command,
							concatenation (<<cmd.generator, "'s operand">>),
							false)
				check
					selection_valid: rr_cmd /= Void
				end
				cmd.set_operand (rr_cmd)
			end
		end

	edit_offset (cmd: SETTABLE_OFFSET_COMMAND) is
			-- Edit a SETTABLE_OFFSET_COMMAND.
		local
			unop: UNARY_OPERATOR [ANY, REAL]
		do
			unop ?= cmd
			check
				cmd_is_a_unop_real: unop /= Void
			end
			edit_unaryop (unop)
			edit_mtlist (cmd)
			cmd.set_offset (user_interface.integer_selection (
						concatenation (<<cmd.generator, "'s offset value">>)))
		end

	edit_boolean_numeric_client (cmd: BOOLEAN_NUMERIC_CLIENT) is
			-- Edit a BOOLEAN_NUMERIC_CLIENT.
		local
			binop: BINARY_OPERATOR [BOOLEAN, REAL]
			result_cmd: RESULT_COMMAND [REAL]
		do
			-- Obtain and set cmd's boolean operator.
			binop ?= user_interface.command_selection (
						user_interface.Binary_boolean_real_command,
							concatenation (<<cmd.generator,
								"'s boolean operator">>), false)
			check
				selection_valid: binop /= Void
			end
			cmd.set_boolean_operator (binop)
			-- Obtain and set cmd's true command.
			result_cmd ?= user_interface.command_selection (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s true command">>), false)
			check
				selection_valid: result_cmd /= Void
			end
			cmd.set_true_cmd (result_cmd)
			-- Obtain and set cmd's false command.
			result_cmd ?= user_interface.command_selection (
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
			left ?= user_interface.command_selection (
						user_interface.Real_result_command,
								concatenation (<<cmd.generator,
									"'s left operand">>), false)
			right ?= user_interface.command_selection (
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

end -- APPLICATION_COMMAND_EDITOR
