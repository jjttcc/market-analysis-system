note
	description:
		"Builder/editor of COMMANDs using a command-line interface"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CL_BASED_COMMAND_EDITING_INTERFACE inherit

	MAS_COMMAND_LINE_UTILITIES
		rename
			print_message as show_message
		export
			{NONE} all
		end

	COMMAND_EDITING_INTERFACE
		undefine
			print
		end

creation

	make

feature -- Initialization

	make (use_mktfnc_selection: BOOLEAN)
		do
			create editor.make (Current)
			use_market_function_selection := use_mktfnc_selection
		ensure
			editor_exists: editor /= Void
			mfsa_set:
				use_market_function_selection = use_mktfnc_selection
		end

feature -- Basic operations

	print_command_tree (cmd: COMMAND; level: INTEGER)
			-- Print the type name of `cmd' and, recursively, that of all
			-- of its operands.
		local
			i: INTEGER
			s: STRING
		do
			from
				i := 1
			until
				i = level
			loop
				print ("  ")
				i := i + 1
			end
			s := cmd.generator
			if cmd.name /= Void and then not cmd.name.is_empty then
				s := s + " [" + cmd.name + "]"
			end
			print (s + "%N")
			debug ("object_editing")
				print_list (<<"(", cmd.out, ")%N">>)
			end
			print_operand_trees (cmd, level + 1)
		end

feature -- Status setting

	set_input_device (arg: IO_MEDIUM)
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
		ensure
			input_device_set: input_device = arg and input_device /= Void
		end

	set_output_device (arg: IO_MEDIUM)
			-- Set output_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_device := arg
		ensure
			output_device_set: output_device = arg and output_device /= Void
		end


feature {NONE} -- Hook methods

	accepted_by_user (c: COMMAND): BOOLEAN
		local
			editable: CONFIGURABLE_EDITABLE_COMMAND
		do
			print (display_for_accepted_by_user (c) + eom)
			editable_state := False; editing_needed := False
			inspect
				character_selection (Void)
			when 'd', 'D' then
				print_list (<<"%N", command_description (c),
					"%N%NChoose ", c.generator + name_for (c),
						"? (y/n) ", eom>>)
				inspect
					character_selection (Void)
				when 'y', 'Y' then
					Result := True
				else
					check Result = False end
				end
			when 'c', 'C' then
				Result := True
			when 'e', 'E' then
				if do_clone then
					-- The chosen command should not be editied if
					-- do_clone is False.
					editing_needed := True
					user_specified_command_name := visible_string_selection (
						"Enter a name for " + c.generator + ": ")
					editable ?= c
					if editable /= Void then
						inspect
							character_selection ("Make " + c.generator +
							" editable ? (y/n) ")
						when 'y', 'Y' then
							editable_state := True
						else
							-- Null action
						end
					end
					Result := True
				end
			else
				check Result = False end
			end
		end

feature {NONE} -- Utility routines

	guarded_print_command_tree (cmd: COMMAND; level: INTEGER; opname: STRING;
				parent: COMMAND)
			-- Call `print_command_tree' with a guard that ensures it is not
			-- called if `cmd' is void.  Log an appropriate error message
			-- (with `report_errors') if `cmd' is void.
		do
			if cmd = Void then
				last_error := "[Warning: " + opname
				if parent.name /= Void and then not parent.name.is_empty then
					last_error := last_error + " (" + parent.name + ")"
				end
				last_error := last_error + " does not exist.]%N"
				error_occurred := True
				report_errors
			else
				print_command_tree (cmd, level)
			end
		end

	print_operand_trees (cmd: COMMAND; level: INTEGER)
			-- Call print_command_tree on all of `cmd's operands, if
			-- it has any.
		local
			-- These three are the only command types that have operands.
			unop: UNARY_OPERATOR [ANY, ANY]
			binop: BINARY_OPERATOR [ANY, ANY]
			bool_client: NUMERIC_CONDITIONAL_COMMAND
			num_wrapper: NUMERIC_VALUED_COMMAND_WRAPPER
			cmd_seq: COMMAND_SEQUENCE
		do
			unop ?= cmd
			binop ?= cmd
			bool_client ?= cmd
			num_wrapper ?= cmd
			cmd_seq ?= cmd
			if unop /= Void then
				guarded_print_command_tree (unop.operand, level,
					"unary operator's operand", unop)
			elseif binop /= Void then
				guarded_print_command_tree (binop.operand1, level,
					"binary operator's left operand", binop)
				guarded_print_command_tree (binop.operand2, level,
					"binary operator's right operand", binop)
			elseif bool_client /= Void then
				guarded_print_command_tree (bool_client.boolean_operator, level,
					"boolean client's boolean operator", bool_client)
				guarded_print_command_tree (bool_client.false_cmd, level,
					"boolean client's false command", bool_client)
				guarded_print_command_tree (bool_client.true_cmd, level,
					"boolean client's true command", bool_client)
			elseif num_wrapper /= Void then
				guarded_print_command_tree (num_wrapper.item, level,
					"numeric command wrapper's operand", num_wrapper)
			elseif cmd_seq /= Void then
				cmd_seq.children.do_all (agent guarded_print_command_tree (?,
					level, "command sequence's operand", cmd_seq))
			else
				debug ("operator-report")
					print ("print_operand_trees: cmd (" + cmd.generator +
						") assumed to have no children.%N")
				end
			end
		end

	display_for_accepted_by_user (c: COMMAND): STRING
		local
			text: LINKED_LIST [STRING]
			margin: STRING
			line_length: INTEGER
		do
			line_length := 76
			margin := "     "
			create text.make
			text.extend ("Select:%N     Print description of " +
				c.generator + name_for (c) + "? (d)")
			text.extend ("Choose " + c.generator + name_for (c) + " (c)")
			text.extend ("filler")
			text.extend ("Make another choice (a)")
			Result := text @ 1
			if do_clone then
				text.put_i_th ("Choose " + c.generator +
					" and edit its settings (e)", 3)
				if (text @ 1).count + (text @ 2).count > line_length then
					Result.append ("%N" + margin + text @ 2)
				else
					Result.append (" " + text @ 2)
				end
				Result.append ("%N" + margin + text @ 3 + " " + "%N" + margin +
					text @ 4 + " ")
			else
				if (text @ 1).count + (text @ 2).count > line_length then
					Result.append ("%N" + margin + text @ 2)
				else
					Result.append (" " + text @ 2)
				end
				Result.append ("%N" + margin + text @ 4 + " ")
			end
		end

end -- CL_BASED_COMMAND_EDITING_INTERFACE
