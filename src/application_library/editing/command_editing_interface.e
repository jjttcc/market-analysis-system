indexing
	description:
		"Abstraction for a user interface that obtains selections needed for %
		%editing of COMMANDs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class COMMAND_EDITING_INTERFACE inherit

	COMMANDS
		export
			{NONE} all
		end

	OBJECT_EDITING_INTERFACE [COMMAND]
		rename
			object_selection_from_type as command_selection_from_type,
			object_types as command_types,
			user_object_selection as user_command_selection,
			initialize_object as initialize_command,
			current_objects as current_commands
		redefine
			editor, command_types
		end

feature -- Access

	editor: APPLICATION_COMMAND_EDITOR
			-- Editor used to set COMMANDs' operands and parameters

	left_offset: INTEGER
			-- Largest left offset value used by any of the created operators
			-- for a particular operator "tree" - Note that this value must
			-- be explicitly set to 0 before the creation/editing of a new
			-- operator "tree".

	market_function: MARKET_FUNCTION
			-- Market function to use for those commands that need it

feature -- Constants

	Boolean_result_command: STRING is "RESULT_COMMAND [BOOLEAN]"
			-- Name of result command with a BOOLEAN generic parameter

	Real_result_command: STRING is "RESULT_COMMAND [REAL]"
			-- Name of result command with a REAL generic parameter

	Binary_boolean_real_command: STRING is "BINARY_OPERATOR [BOOLEAN, REAL]"
			-- Name of binary command with BOOLEAN, REAL generic parameters

	Basic_numeric_command: STRING is "BASIC_NUMERIC_COMMAND"
			-- Name of BASIC_NUMERIC_COMMAND

feature -- Status setting

	set_left_offset (arg: INTEGER) is
			-- Set left_offset to `arg'.
		require
			arg_not_negative: arg >= 0
		do
			left_offset := arg
		ensure
			left_offset_set: left_offset = arg and left_offset >= 0
		end

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
		deferred
		end

feature {APPLICATION_COMMAND_EDITOR} -- Access

	command_types: HASH_TABLE [ARRAYED_LIST [COMMAND], STRING] is
			-- Hash table of lists of command instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
		local
			l: ARRAYED_LIST [COMMAND]
		once
			!!Result.make (0)
			!!l.make (13)
			Result.extend (l, Boolean_result_command)
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
			l.extend (command_with_generator ("SIGN_ANALYZER"))
			!!l.make (22)
			Result.extend (l, Real_result_command)
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
			l.extend (command_with_generator ("OPENING_PRICE"))
			l.extend (command_with_generator ("OPEN_INTEREST"))
			l.extend (command_with_generator ("BASIC_LINEAR_COMMAND"))
			l.extend (command_with_generator ("BOOLEAN_NUMERIC_CLIENT"))
			l.extend (command_with_generator ("SLOPE_ANALYZER"))
			!!l.make (6)
			Result.extend (l, Binary_boolean_real_command)
			l.extend (command_with_generator ("LE_OPERATOR"))
			l.extend (command_with_generator ("GE_OPERATOR"))
			l.extend (command_with_generator ("EQ_OPERATOR"))
			l.extend (command_with_generator ("LT_OPERATOR"))
			l.extend (command_with_generator ("GT_OPERATOR"))
			l.extend (command_with_generator ("SIGN_ANALYZER"))
			!!l.make (9)
			Result.extend (l, Basic_numeric_command)
			l.extend (command_with_generator ("BASIC_NUMERIC_COMMAND"))
			l.extend (command_with_generator ("OPENING_PRICE"))
			l.extend (command_with_generator ("OPEN_INTEREST"))
			l.extend (command_with_generator ("VOLUME"))
			l.extend (command_with_generator ("LOW_PRICE"))
			l.extend (command_with_generator ("HIGH_PRICE"))
			l.extend (command_with_generator ("CLOSING_PRICE"))
			l.extend (command_with_generator ("OPENING_PRICE"))
			l.extend (command_with_generator ("OPEN_INTEREST"))
		end

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
		do
			check
				mf_not_void: market_function /= Void
			end
			Result := market_function.output
		end

feature {NONE} -- Implementation

	Binary_boolean,		-- binary operator with boolean result
	Binary_real,		-- binary operator with real result
	Constant,			-- CONSTANT - needs value to be set
	Other,				-- Classes that need no initialization
	Mtlist_resultreal_n,-- Classes that need a market tuple list, a
						-- RESULT_COMMAND [REAL], and an n-value
	N_command,			-- Classes that (only) need an n-value
	Mtlist,				-- Classes that (only) need a market tuple list
	Settable_offset,	-- SETTABLE_OFFSET_COMMAND
	Sign_analyzer,		-- SIGN_ANALYZER
	Boolean_num_client	-- BOOLEAN_NUMERIC_CLIENT
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
			name := "N_VALUE_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (N_command, name)
			name := "MA_EXPONENTIAL"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (N_command, name)
			name := "SETTABLE_OFFSET_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Settable_offset, name)
			name := "VOLUME"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "LOW_PRICE"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "HIGH_PRICE"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "CLOSING_PRICE"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "OPENING_PRICE"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "OPEN_INTEREST"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := "BASIC_LINEAR_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist, name)
			name := "BOOLEAN_NUMERIC_CLIENT"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Boolean_num_client, name)
			name := "SIGN_ANALYZER"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Sign_analyzer, name)
			name := "SLOPE_ANALYZER"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist, name)
		end

	initialize_command (c: COMMAND) is
			-- Set command parameters - operands, etc.
		local
			const: CONSTANT
			bin_bool_op: BINARY_OPERATOR [ANY, BOOLEAN]
			bin_real_op: BINARY_OPERATOR [ANY, REAL]
			unop_real: UNARY_OPERATOR [ANY, REAL]
			offset_cmd: SETTABLE_OFFSET_COMMAND
			bnc: BOOLEAN_NUMERIC_CLIENT
			sign_an: SIGN_ANALYZER
		do
			inspect
				initialization_map @ c.generator
			when Binary_boolean then
				bin_bool_op ?= c
				check
					c_is_a_binary_boolean: bin_bool_op /= Void
				end
				editor.edit_binary_boolean (bin_bool_op)
			when Binary_real then
				bin_real_op ?= c
				check
					c_is_a_binary_realean: bin_real_op /= Void
				end
				editor.edit_binary_real (bin_real_op)
			when Constant then
				const ?= c
				check
					c_is_a_constant: const /= Void
				end
				editor.edit_constant (const)
			when Mtlist_resultreal_n then
				unop_real ?= c
				check
					c_is_a_unary_operator_real: unop_real /= Void
				end
				editor.edit_mtlist_resultreal_n (unop_real)
			when Other then
				-- No initialization needed.
			when N_command then
				editor.edit_n (c)
			when Mtlist then
				editor.edit_mtlist (c)
			when Settable_offset then
				offset_cmd ?= c
				check
					c_is_a_settable_offset_cmd: offset_cmd /= Void
				end
				editor.edit_offset (offset_cmd)
			when Boolean_num_client then
				bnc ?= c
				check
					c_is_a_boolean_numeric_client: bnc /= Void
				end
				editor.edit_boolean_numeric_client (bnc)
			when Sign_analyzer then
				sign_an ?= c
				check
					c_is_a_sign_analyzer: sign_an /= Void
				end
				editor.edit_sign_analyzer (sign_an)
			end
		end

feature -- Implementation - options

	initialization_needed: BOOLEAN is true

	clone_needed: BOOLEAN is true

invariant

	init_clone_needed: initialization_needed = true and clone_needed = true

end -- COMMAND_EDITING_INTERFACE
