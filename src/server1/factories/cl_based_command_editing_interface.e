indexing
	description:
		"Abstraction that allows the user to build COMMANDs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMMAND_BUILDER inherit

	UI_UTILITIES
		export
			{NONE} all
		end

	PRINTING
		export
			{NONE} all
		end

	COMMAND_EDITING_INTERFACE

feature -- Access

	market_function: MARKET_FUNCTION
			-- Market function to use for those commands that need it

	integer_selection (msg: STRING): INTEGER is
		do
			print_list (<<"Enter an integer value for ", msg, ": ">>)
			read_integer
			Result := last_integer
		end

	real_selection (msg: STRING): REAL is
		do
			print_list (<<"Enter a real value for ", msg, ": ">>)
			read_real
			Result := last_real
		end

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
		do
			-- !!!May need to retrieve market function from user?
			check
				mf_not_void: market_function /= Void
			end
			Result := market_function.output
		end

	show_message (msg: STRING) is
		do
			print_list (<<msg, "%N">>)
		end

feature -- Status setting

	set_market_function (arg: MARKET_FUNCTION) is
			-- Set market_function to `arg'.
		require
			arg_not_void: arg /= Void
		do
			market_function := arg
		ensure
			market_function_set: market_function = arg and
				market_function /= Void
		end

feature -- Miscellaneous

	print_command_tree (cmd: COMMAND; level: INTEGER) is
			-- Print the type name of `cmd' and, recursively, that of all
			-- of its operands.
		require
			not_void: cmd /= Void
			level_positive: level > 0
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
			print_list (<<cmd.generator, "%N">>)
			debug ("command_editing")
			print_list (<<"(", cmd.out, ")%N">>)
			end
			print_operand_trees (cmd, level + 1)
		end

feature {NONE} -- Hook methods

	user_command_selection (cmds: LIST [COMMAND]; msg: STRING):
				COMMAND is
		local
			op_names, tree_names: ARRAYED_LIST [STRING]
			tree_cmds: LIST [COMMAND]
			shared: BOOLEAN -- Should the selected command be shared?
			name_choice: STRING
			cmd_choice: COMMAND
		do
			tree_cmds := valid_types (cmds, current_commands)
			from
				!!tree_names.make (tree_cmds.count)
				tree_cmds.start
			until
				tree_cmds.exhausted
			loop
				tree_names.extend (tree_cmds.item.generator)
				tree_cmds.forth
			end
			from
				!!op_names.make (cmds.count)
				cmds.start
			until
				cmds.exhausted
			loop
				op_names.extend (cmds.item.generator)
				cmds.forth
			end
			from
			until
				Result /= Void
			loop
				print_list (<<"Select an operator for ", msg,
					" from either the%Nlist of valid operators currently %
					%in the tree (which will be shared)%Nor a new operator %
					%from the list of all valid operators:%N">>)
				if not tree_names.empty then
					print ("[Valid operators currently in the tree:]%N")
					print_names_in_1_column (tree_names, 1)
				else
					print ("[There are currently no valid operators in the %
							%tree.]%N")
				end
				print ("[List of all valid operators:]%N")
				print_names_in_1_column (op_names, tree_names.count + 1)
				read_integer
				if
					last_integer < 1 or
						last_integer > tree_names.count + op_names.count
				then
					print_list (<<"Selection must be between 1 and ",
								tree_names.count + op_names.count, "%N">>)
				else
					if last_integer > tree_names.count then
						name_choice :=
							op_names @ (last_integer - tree_names.count)
						cmd_choice := cmds @ (last_integer - tree_names.count)
						shared := false
					else
						name_choice := tree_names @ last_integer
						cmd_choice := tree_cmds @ last_integer
						shared := true
					end
					print_list (<<"Select:%N     Print description of ",
								name_choice, "? (d)%N",
								"     Choose ", name_choice,
								" (c) Make another choice (a) ">>)
					inspect
						selected_character
					when 'd', 'D' then
						print_list (<<"%N", command_description (
							cmd_choice),
							"%N%NChoose ", name_choice,
								"? (y/n) ">>)
						inspect
							selected_character
						when 'y', 'Y' then
							Result := cmd_choice
						else
						end
					when 'c', 'C' then
						Result := cmd_choice
					else
					end
				end
			end
			if not shared then
				Result := deep_clone (Result)
			end
		end

	do_choice (descr: STRING; choices: LIST [PAIR [STRING, BOOLEAN]];
				allowed_selections: INTEGER) is
		local
			finished, choice_made: BOOLEAN
			slimit: INTEGER
			names: ARRAYED_LIST [STRING]
		do
			from
				slimit := allowed_selections
				print_list (<<descr, "%N(Up to ",
							allowed_selections, " choices)%N">>)
				from
					!!names.make (choices.count)
					choices.start
				until
					choices.exhausted
				loop
					names.extend (choices.item.left)
					choices.forth
				end
			until
				slimit = 0 or finished
			loop
				from
					choice_made := false
				until
					choice_made
				loop
					print ("Select an item (0 to end):%N")
					print_names_in_1_column (names, 1)
					read_integer
					if last_integer <= -1 or last_integer > choices.count then
						print_list (<<"Selection must be between 0 and ",
									choices.count, "%N">>)
					elseif last_integer = 0 then
						finished := true
						choice_made := true
					else
						print_list (<<"Added %"", names @ last_integer,
									"%"%N">>)
						choices.i_th (last_integer).set_right (true)
						choice_made := true
					end
				end
				slimit := slimit - 1
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

end -- COMMAND_BUILDER
