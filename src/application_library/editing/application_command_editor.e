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
		local
			left, right: RESULT_COMMAND [BOOLEAN]
		do
			left ?= user_interface.command_selection (
						user_interface.Boolean_result_command,
										<<c.generator, "'s left operand">>)
			right ?= user_interface.command_selection (
						user_interface.Boolean_result_command,
										<<c.generator, "'s right operand">>)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_binary_real (cmd: BINARY_OPERATOR [ANY, REAL]) is
			-- Edit a BINARY_OPERATOR that takes REAL operands.
		local
			left, right: RESULT_COMMAND [REAL]
		do
			left ?= user_interface.command_selection (
						user_interface.Real_result_command,
										<<c.generator, "'s left operand">>)
			right ?= user_interface.command_selection (
						user_interface.Real_result_command,
										<<c.generator, "'s right operand">>)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_mtlist_resultreal_n (c: COMMAND) is
			-- Edit `c's market tuple list, operator (
			-- RESULT_COMMAND [REAL]), and n-value.
		do
			edit_n (c)
			edit_mtlist (c)
			edit_unaryop (c)
		end

	edit_n (c: COMMAND) is
			-- Edit `c's n-value.
		local
			cmd: N_RECORD_COMMAND
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			cmd.set_n (user_interface.integer_selection (
						<<cmd.generator, "'s n-value">>))
		end

	edit_mtlist (c: COMMAND) is
			-- Edit `c's market tuple list target.
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
								<<c.generator, "'s operand">>)
				check
					selection_valid: bnc_cmd /= Void
				end
				hv.set_operand (bnc_cmd)
			elseif lv /= Void then
				bnc_cmd ?= user_interface.command_selection (
							user_interface.Basic_numeric_command,
								<<c.generator, "'s operand">>)
				check
					selection_valid: bnc_cmd /= Void
				end
				lv.set_operand (bnc_cmd)
			else
				rr_cmd ?= user_interface.command_selection (
							user_interface.Real_result_command,
									<<c.generator, "'s operand">>)
				check
					selection_valid: rr_cmd /= Void
				end
				cmd.set_operand (rr_cmd)
			end
		end

	edit_constant (cmd: CONSTANT) is
			-- Edit a simple command that takes a REAL value
			-- (such as CONSTANT).
		local
			x: REAL
		do
			cmd.set_constant_value (user_interface.real_selection (
									<<cmd.generator, "'s value">>))
		end

end -- APPLICATION_COMMAND_EDITOR
