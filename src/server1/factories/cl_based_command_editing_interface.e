indexing
	description:
		"Builder/editor of COMMANDs using a command-line interface"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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

	make (use_mktfnc_selection: BOOLEAN) is
		do
			create editor.make (Current)
			use_market_function_selection := use_mktfnc_selection
		ensure
			editor_exists: editor /= Void
			mfsa_set:
				use_market_function_selection = use_mktfnc_selection
		end

feature -- Basic operations

	print_command_tree (o: COMMAND; level: INTEGER) is
			-- Print the type name of `o' and, recursively, that of all
			-- of its operands.
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i = level
			loop
				print ("  ")
				i := i + 1
			end
			print_list (<<o.generator, "%N">>)
			debug ("object_editing")
				print_list (<<"(", o.out, ")%N">>)
			end
			print_operand_trees (o, level + 1)
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

	display_for_accepted_by_user (c: COMMAND): STRING is
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
