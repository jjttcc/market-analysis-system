indexing
	description:
		"Builder/editor of COMMANDs using a command-line interface"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class CL_BASED_COMMAND_EDITING_INTERFACE inherit

	COMMAND_LINE_UTILITIES [COMMAND]
		rename
			print_object_tree as print_command_tree,
			print_component_trees as print_operand_trees,
			print_message as show_message
		export
			{NONE} all
		redefine
			print_operand_trees
		end

	COMMAND_EDITING_INTERFACE
		undefine
			print
		end

creation

	make

feature -- Initialization

	make (use_mktfnc_selection: BOOLEAN) is
		do
			!!editor.make (Current)
			use_market_function_selection := use_mktfnc_selection
		ensure
			editor_exists: editor /= Void
			mfsa_set:
				use_market_function_selection = use_mktfnc_selection
		end

feature -- Status setting

	set_input_device (arg: IO_MEDIUM) is
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
		ensure
			input_device_set: input_device = arg and input_device /= Void
		end

	set_output_device (arg: IO_MEDIUM) is
			-- Set output_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_device := arg
		ensure
			output_device_set: output_device = arg and output_device /= Void
		end


feature {NONE} -- Hook methods

	accepted_by_user (c: COMMAND): BOOLEAN is
		do
			print_list (<<"Select:%N     Print description of ",
						c.generator, "? (d)%N",
						"     Choose ", c.generator,
						" (c) Make another choice (a) ", eom>>)
			inspect
				selected_character
			when 'd', 'D' then
				print_list (<<"%N", command_description (c),
					"%N%NChoose ", c.generator,
						"? (y/n) ", eom>>)
				inspect
					selected_character
				when 'y', 'Y' then
					Result := true
				else
					check Result = false end
				end
			when 'c', 'C' then
				Result := true
			else
				check Result = false end
			end
		end

feature {NONE} -- Utility routines

	print_operand_trees (cmd: COMMAND; level: INTEGER) is
			-- Call print_command_tree on all of `cmd's operands, if
			-- it has any.
		local
			-- These three are the only command types that have operands.
			unop: UNARY_OPERATOR [ANY, ANY]
			binop: BINARY_OPERATOR [ANY, ANY]
			bool_client: BOOLEAN_NUMERIC_CLIENT
		do
			unop ?= cmd
			binop ?= cmd
			bool_client ?= cmd
			if unop /= Void then
				print_command_tree (unop.operand, level)
			elseif binop /= Void then
				print_command_tree (binop.operand1, level)
				print_command_tree (binop.operand2, level)
			elseif bool_client /= Void then
				print_command_tree (bool_client.boolean_operator, level)
				print_command_tree (bool_client.false_cmd, level)
				print_command_tree (bool_client.true_cmd, level)
			end
		end

end -- CL_BASED_COMMAND_EDITING_INTERFACE
