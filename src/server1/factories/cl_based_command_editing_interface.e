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

	COMMAND_EDITOR
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

--!!!CHANGE - if possible, (like result_command_list) make this generic
--!!!based on a type (STRING) argument specifying "BOOLEAN", "REAL", etc.
-----------CHANGE probably still valid - with type/ANY...
--!!!Can then get by with only one function.  (Caller will probably have
--!!!to use assignment attempt, e.g., for RESULT_COMMAND [BOOLEAN], since
--!!!the return type here will need to change to RESULT_COMMAND [ANY]
	boolean_result_command (msg: ARRAY [STRING]): RESULT_COMMAND [BOOLEAN] is
			-- A boolean result command built by the user
		local
			op_names: ARRAYED_LIST [STRING]
			type: BOOLEAN
		do
			from
				!!op_names.make (result_command_list (type).count)
				result_command_list (type).start
			until
				result_command_list (type).exhausted
			loop
				op_names.extend (result_command_list (type).item.generator)
				result_command_list (type).forth
			end
			from
			until
				Result /= Void
			loop
				print_selection_msg ("Select the desired operator type",
					" for ", msg)
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
							result_command_list (type) @ last_integer),
							"%N%NChoose ", op_names @ last_integer,
								"? (y/n) ">>)
						inspect
							selected_character
						when 'y', 'Y' then
							Result ?= deep_clone (
								result_command_list (type) @ last_integer)
						else
						end
					when 'c', 'C' then
						Result ?= deep_clone (
							result_command_list (type) @ last_integer)
					else
					end
				end
			end
			initialize_command (Result)
		end

	real_result_command (msg: ARRAY [STRING]): RESULT_COMMAND [REAL] is
			-- A real result command built by the user
			-- (Sorry about the code duplication. -- Can they be merged?!!!)
		local
			op_names: ARRAYED_LIST [STRING]
			type: REAL
		do
			from
				!!op_names.make (result_command_list (type).count)
				result_command_list (type).start
			until
				result_command_list (type).exhausted
			loop
				op_names.extend (result_command_list (type).item.generator)
				result_command_list (type).forth
			end
			from
			until
				Result /= Void
			loop
				print_selection_msg ("Select the desired operator type",
					" for ", msg)
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
							result_command_list (type) @ last_integer),
							"%N%NChoose ", op_names @ last_integer,
								"? (y/n) ">>)
						inspect
							selected_character
						when 'y', 'Y' then
							Result ?= deep_clone (
								result_command_list (type) @ last_integer)
							check Result /= Void end
						else
						end
					when 'c', 'C' then
						Result ?= deep_clone (
							result_command_list (type) @ last_integer)
						check Result /= Void end
					else
					end
				end
			end
			initialize_command (Result)
		end

	basic_numeric_command (msg: ARRAY [STRING]): BASIC_NUMERIC_COMMAND is
			-- A BASIC_NUMERIC_COMMAND built by the user
			-- (More code duplication! -- Can they be merged?!!!)
		local
			op_names: ARRAYED_LIST [STRING]
		do
			from
				!!op_names.make (basic_numeric_command_list.count)
				basic_numeric_command_list.start
			until
				basic_numeric_command_list.exhausted
			loop
				op_names.extend (basic_numeric_command_list.item.generator)
				basic_numeric_command_list.forth
			end
			from
			until
				Result /= Void
			loop
				print_selection_msg ("Select the desired operator type",
					" for ", msg)
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
							basic_numeric_command_list @ last_integer),
							"%N%NChoose ", op_names @ last_integer,
								"? (y/n) ">>)
						inspect
							selected_character
						when 'y', 'Y' then
							Result := deep_clone (
								basic_numeric_command_list @ last_integer)
						else
						end
					when 'c', 'C' then
						Result := deep_clone (
							basic_numeric_command_list @ last_integer)
					else
					end
				end
			end
			initialize_command (Result)
		end

--!!!!Is this function needed??
	real_unary_op (msg: ARRAY [STRING]): UNARY_OPERATOR [REAL, REAL] is
			-- A unary op, built by the user, whose result and operand
			-- types are REAL
			-- (More code duplication.!!!)
		local
			op_names: ARRAYED_LIST [STRING]
		do
			from
				!!op_names.make (real_unary_op_list.count)
				real_unary_op_list.start
			until
				real_unary_op_list.exhausted
			loop
				op_names.extend (real_unary_op_list.item.generator)
				real_unary_op_list.forth
			end
			from
			until
				Result /= Void
			loop
				print_selection_msg ("Select the desired operator type",
					" for ", msg)
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
							real_unary_op_list @ last_integer),
							"%N%NChoose ", op_names @ last_integer,
								"? (y/n) ">>)
						inspect
							selected_character
						when 'y', 'Y' then
							Result := deep_clone (
								real_unary_op_list @ last_integer)
						else
						end
					when 'c', 'C' then
						Result := deep_clone (
							real_unary_op_list @ last_integer)
					else
					end
				end
			end
		end

feature {NONE} -- Implementation

	command_types: HASH_TABLE [ARRAYED_LIST [COMMAND], STRING] is
			-- Hash table of lists of command instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
		local
			l: ARRAYED_LIST [COMMAND]
		once
			!!Result.make (0)
			!!l.make (0)
			Result.extend (l, "RESULT_COMMAND [BOOLEAN]")
			l.extend (command_with_generator ("LE_OPERATOR"))
			l.extend (command_with_generator ("GE_OPERATOR"))
			l.extend (command_with_generator ("EQ_OPERATOR"))
			l.extend (command_with_generator ("LT_OPERATOR"))
			l.extend (command_with_generator ("GT_OPERATOR"))
			l.extend (command_with_generator ("XOR_OPERATOR"))
			l.extend (command_with_generator ("OR_OPERATOR"))
			l.extend (command_with_generator ("IMPLICATION_OPERATOR"))
			l.extend (command_with_generator ("EQUIVALENCE_OPERATOR"))
			l.extend (command_with_generator ("AND_OPERATOR"))
			l.extend (command_with_generator ("TRUE_COMMAND"))
			l.extend (command_with_generator ("FALSE_COMMAND"))
			!!l.make (0)
			Result.extend (l, "RESULT_COMMAND [REAL]")
			l.extend (command_with_generator ("SUBTRACTION"))
			l.extend (command_with_generator ("MULTIPLICATION"))
			l.extend (command_with_generator ("DIVISION"))
			l.extend (command_with_generator ("ADDITION"))
			l.extend (command_with_generator ("LOWEST_VALUE"))
			l.extend (command_with_generator ("LINEAR_SUM"))
			l.extend (command_with_generator ("HIGHEST_VALUE"))
			l.extend (command_with_generator ("N_VALUE_COMMAND"))
			l.extend (command_with_generator ("MA_EXPONENTIAL"))
			l.extend (command_with_generator ("SETTABLE_OFFSET_COMMAND"))
			l.extend (command_with_generator ("MINUS_N_COMMAND"))
			l.extend (command_with_generator ("CONSTANT"))
			l.extend (command_with_generator ("BASIC_NUMERIC_COMMAND"))
			l.extend (command_with_generator ("VOLUME"))
			l.extend (command_with_generator ("LOW_PRICE"))
			l.extend (command_with_generator ("HIGH_PRICE"))
			l.extend (command_with_generator ("CLOSING_PRICE"))
			l.extend (command_with_generator ("BASIC_LINEAR_COMMAND"))
			l.extend (command_with_generator ("BOOLEAN_NUMERIC_CLIENT"))
		end

	result_command_list (type: ANY):
				LINKED_LIST [RESULT_COMMAND [ANY]] is
			-- List of all classes that conform to RESULT_COMMAND whose
			-- `value' attributes are of type `type'
			-- (Cannot use assignment attempt to, for example,
			-- RESULT_COMMAND [REAL] because of a bug in the ISE compiler;
			-- however, using typename allows using just one function.
		local
			cmd: RESULT_COMMAND [ANY]
		once
			!!Result.make
			from
				command_instances.start
			until
				command_instances.exhausted
			loop
				cmd ?= command_instances.item
				if cmd /= Void and cmd.value = Void then
					print ("cmd.value is Void.%N")
				else
					print_list (<<"cmd.value: ", cmd.value.out, "%N">>)
				end
				print ("About to crash???%N%N%N")
				if cmd /= Void and cmd.value.conforms_to (type) then
					Result.extend (cmd)
				end
				command_instances.forth
			end
		end

	real_result_command_list: LINKED_LIST [RESULT_COMMAND [REAL]] is
			-- List of all classes that conform to RESULT_COMMAND [REAL]
		local
			cmd: RESULT_COMMAND [REAL]
		once
			print ("real_result_command_list:%N")
			!!Result.make
			from
				command_instances.start
			until
				command_instances.exhausted
			loop
				cmd ?= command_instances.item
				if cmd /= Void then
					print_list (<<"Adding ", cmd.generator, ".%N">>)
					Result.extend (cmd)
				end
				command_instances.forth
			end
		end

	basic_numeric_command_list: LINKED_LIST [BASIC_NUMERIC_COMMAND] is
			-- List of all classes that conform to BASIC_NUMERIC_COMMAND
		local
			result_cmd: BASIC_NUMERIC_COMMAND
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

--!!!!Is this function needed??
	real_unary_op_list: LINKED_LIST [UNARY_OPERATOR [REAL, REAL]] is
			-- List of all classes that conform to UNARY_OPERATOR [REAL, REAL]
		local
			cmd: UNARY_OPERATOR [REAL, REAL]
		once
			!!Result.make
			from
				command_instances.start
			until
				command_instances.exhausted
			loop
				cmd ?= command_instances.item
				if cmd /= Void then
					Result.extend (cmd)
				end
				command_instances.forth
			end
		end

	Binary_boolean, -- binary operator with boolean result
	Binary_real, -- binary operator with real result
	Constant, -- CONSTANT - needs value to be set
	Other, -- Classes that need no initialization
	Mtlist_resultreal_n -- Classes that need a market tuple list, a
				-- RESULT_COMMAND [REAL], and an n-value
	:
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
			name := "BASIC_NUMERIC_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "HIGHEST_VALUE"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal_n, name)
			name := "LOWEST_VALUE"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal_n, name)
			name := "LINEAR_SUM"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal_n, name)
			name := "MINUS_N_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal_n, name)
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
			when Mtlist_resultreal_n then
				mtlist_resultreal_n_init (c)
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
			check
				c_is_valid_type: cmd /= Void
			end
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
			check
				c_is_valid_type: cmd /= Void
			end
			cmd.set_operands (left, right)
		end

	mtlist_resultreal_n_init (c: COMMAND) is
			-- Initialize `c's market tuple list, operator (
			-- RESULT_COMMAND [REAL]), and n-value.
		do
			n_init (c)
			mtlist_init (c)
			unaryop_init (c)
		end

	n_init (c: COMMAND) is
			-- Initialize `c's n-value.
		local
			cmd: N_RECORD_COMMAND
			n: INTEGER
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			--!!!Ask user for the value of n and set `n' to it.
			cmd.set_n (n)
		end

	mtlist_init (c: COMMAND) is
			-- Initialize `c's market tuple list target.
		local
			cmd: LINEAR_COMMAND
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			if market_function /= Void then
				cmd.set_target (market_function.output)
			else
				cmd.set_target (default_market_tuple_list)
			end
		end

	unaryop_init (c: COMMAND) is
			-- Initialize `c's (as a UNARY_OPERATOR) operand.
		local
			cmd: UNARY_OPERATOR [REAL, REAL]
			hv: HIGHEST_VALUE
			lv: LOWEST_VALUE
		do
			cmd ?= c
			if cmd /= Void then
				cmd.set_operand (real_result_command (
									<<c.generator, "'s operand">>))
			else
				hv ?= c
				if hv /= Void then
					hv.set_operand (basic_numeric_command (
									<<c.generator, "'s operand">>))
				else
					lv ?= c
					check
						c_is_valid_type: lv /= Void
					end
					lv.set_operand (basic_numeric_command (
									<<c.generator, "'s operand">>))
				end
			end
		end

	constant_init (c: COMMAND) is
			-- Initialize a simple command that takes a REAL value
			-- (such as CONSTANT).
		local
			cmd: CONSTANT
			x: REAL
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			print_list (<<"Enter the numeric value for ", c.generator,
						": ">>)
			read_real
			x := last_real
			cmd.set_constant_value (x)
		end

feature {NONE} -- Utility routines

	print_selection_msg (s1, s2: STRING; svector: ARRAY [STRING]) is
			-- Print `s1'; and print `svector', if it's not Void; and print
			-- `s2' if both `svector' and `s2' are not void.  Then print
			-- a colon and a new line.
		require
			s1_not_void: s1 /= Void
		do
			print (s1)
			if svector /= Void then
				if s2 /= Void then
					print (s2)
				end
				print_list (svector)
			end
			print (":%N")
		end

end -- COMMAND_BUILDER
