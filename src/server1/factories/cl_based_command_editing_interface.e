indexing
	description:
		"Abstraction that allows the user to build COMMANDs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMMAND_BUILDER inherit

	COMMANDS
		export
			{NONE} all
		end

	UI_UTILITIES
		export
			{NONE} all
		end

	PRINTING
		export
			{NONE} all
		end

feature -- Access

	market_function: MARKET_FUNCTION
			-- Market function to use for those commands that need it

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

feature -- Basic operations

	boolean_result_command (msg: ARRAY [STRING]): RESULT_COMMAND [BOOLEAN] is
			-- A result command built by the user
		local
			op_names: ARRAYED_LIST [STRING]
		do
			from
				!!op_names.make (bool_result_command_list.count)
				bool_result_command_list.start
			until
				bool_result_command_list.exhausted
			loop
				op_names.extend (bool_result_command_list.item.generator)
				bool_result_command_list.forth
			end
			from
			until
				Result /= Void
			loop
				print ("Select the desired operator type")
				if msg /= Void then
					print (" for ")
					print_list (msg)
				end
				print (":%N")
				print_names_in_1_column (op_names)
				read_integer
				if
					last_integer < 1 or
						last_integer > op_names.count
				then
					print_list (<<"Selection must be between 1 and ",
								op_names.count, "%N">>)
				else
					print_list (<<"Select:%N     Print description of ",
								op_names @ last_integer, "? (d)%N",
								"     Choose ", op_names @ last_integer,
								" (c) Make another choice (a) ">>)
					inspect
						selected_character
					when 'd', 'D' then
						print_list (<<"%N", description (
							bool_result_command_list @ last_integer),
							"%N%NChoose ", op_names @ last_integer,
								"? (y/n) ">>)
						inspect
							selected_character
						when 'y', 'Y' then
							Result := deep_clone (
								bool_result_command_list @ last_integer)
						else
						end
					when 'c', 'C' then
						Result := deep_clone (
							bool_result_command_list @ last_integer)
					else
					end
				end
			end
			initialize_command (Result)
		end

	real_result_command (msg: ARRAY [STRING]): RESULT_COMMAND [REAL] is
			-- A result command built by the user
			-- (Sorry about the code duplication.)
		local
			op_names: ARRAYED_LIST [STRING]
		do
			from
				!!op_names.make (real_result_command_list.count)
				real_result_command_list.start
			until
				real_result_command_list.exhausted
			loop
				op_names.extend (real_result_command_list.item.generator)
				real_result_command_list.forth
			end
			from
			until
				Result /= Void
			loop
				print ("Select the desired operator type")
				if msg /= Void then
					print (" for ")
					print_list (msg)
				end
				print (":%N")
				print_names_in_1_column (op_names)
				read_integer
				if
					last_integer < 1 or
						last_integer > op_names.count
				then
					print_list (<<"Selection must be between 1 and ",
								op_names.count, "%N">>)
				else
					print_list (<<"Select:%N     Print description of ",
								op_names @ last_integer, "? (d)%N",
								"     Choose ", op_names @ last_integer,
								" (c) Make another choice (a) ">>)
					inspect
						selected_character
					when 'd', 'D' then
						print_list (<<"%N", description (
							real_result_command_list @ last_integer),
							"%N%NChoose ", op_names @ last_integer,
								"? (y/n) ">>)
						inspect
							selected_character
						when 'y', 'Y' then
							Result := deep_clone (
								real_result_command_list @ last_integer)
						else
						end
					when 'c', 'C' then
						Result := deep_clone (
							real_result_command_list @ last_integer)
					else
					end
				end
			end
			initialize_command (Result)
		end

feature {NONE} -- Implementation

	bool_result_command_list: LINKED_LIST [RESULT_COMMAND [BOOLEAN]] is
			-- List of all classes that conform to RESULT_COMMAND [BOOLEAN]
		local
			result_cmd: RESULT_COMMAND [BOOLEAN]
		once
			!!Result.make
			from
				command_instances.start
			until
				command_instances.exhausted
			loop
				result_cmd ?= command_instances.item
				if result_cmd /= Void then
					Result.extend (result_cmd)
				end
				command_instances.forth
			end
		end

	real_result_command_list: LINKED_LIST [RESULT_COMMAND [REAL]] is
			-- List of all classes that conform to RESULT_COMMAND [REAL]
		local
			result_cmd: RESULT_COMMAND [REAL]
		once
			!!Result.make
			from
				command_instances.start
			until
				command_instances.exhausted
			loop
				result_cmd ?= command_instances.item
				if result_cmd /= Void then
					Result.extend (result_cmd)
				end
				command_instances.forth
			end
		end

	Binary_boolean, Binary_real, Constant, Other:
				INTEGER is unique
			-- Constants identifying initialization routines required for
			-- the different COMMAND types

	initialization_map: HASH_TABLE [INTEGER, STRING] is
			-- Mapping of COMMAND names to initialization classifications
		local
			name: STRING
		once
			!!Result.make (0)
			name := "TRUE_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "FALSE_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "AND_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := "OR_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := "XOR_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := "IMPLICATION_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := "EQUIVALENCE_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := "ADDITION"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "SUBTRACTION"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "MULTIPLICATION"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "DIVISION"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "EQ_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "LT_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "GT_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "GE_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "LE_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := "CONSTANT"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Constant, name)
		end

	initialize_command (c: COMMAND) is
			-- Set command parameters - operands, etc.
		do
			inspect
				initialization_map @ c.generator
			when Binary_boolean then
				binary_boolean_init (c)
			when Binary_real then
				binary_real_init (c)
			when Constant then
				constant_init (c)
			when Other then
				-- No initialization needed.
			end
		end

	binary_boolean_init (c: COMMAND) is
			-- Initialize a BINARY_OPERATOR with BOOLEAN operands.
		local
			left, right: RESULT_COMMAND [BOOLEAN]
			cmd: BINARY_OPERATOR [ANY, BOOLEAN]
		do
			left := boolean_result_command (<<c.generator, "'s left operand">>)
			right := boolean_result_command (<<c.generator,
											"'s right operand">>)
			cmd ?= c
			cmd.set_operands (left, right)
		end

	binary_real_init (c: COMMAND) is
			-- Initialize a BINARY_OPERATOR with REAL operands.
		local
			left, right: RESULT_COMMAND [REAL]
			cmd: BINARY_OPERATOR [ANY, REAL]
		do
			left := real_result_command (<<c.generator, "'s left operand">>)
			right := real_result_command (<<c.generator, "'s right operand">>)
			cmd ?= c
			cmd.set_operands (left, right)
		end

	constant_init (c: COMMAND) is
			-- Initialize a simple command that takes a REAL value
			-- (such as CONSTANT).
		local
			cmd: CONSTANT
			x: REAL
		do
			cmd ?= c
			print_list (<<"Enter the numeric value for ", c.generator,
						": ">>)
			read_real
			x := last_real
			cmd.set_constant_value (x)
		end

end -- COMMAND_BUILDER
