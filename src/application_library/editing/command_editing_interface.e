indexing
	description:
		"Abstraction for a user interface that obtains selections needed for %
		%editing of COMMANDs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class COMMAND_EDITING_INTERFACE inherit

	COMMANDS

	OBJECT_EDITING_INTERFACE [COMMAND]
		rename
			object_selection_from_type as command_selection_from_type,
			object_types as command_types,
			user_object_selection as user_command_selection,
			initialize_object as initialize_command,
			current_objects as current_commands
		redefine
			editor, command_types, descendant_reset
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
			-- Default market function to use for those commands that need it

	market_tuple_selector: MARKET_TUPLE_LIST_SELECTOR
			-- Interface that provides selection of a market tuple list

	command_types: HASH_TABLE [ARRAYED_LIST [COMMAND], STRING] is
			-- Hash table of lists of command instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
		local
			l: ARRAYED_LIST [COMMAND]
		once
			create Result.make (0)

			create l.make (13)
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
			l.extend (command_with_generator ("NOT_OPERATOR"))
			l.extend (command_with_generator ("TRUE_COMMAND"))
			l.extend (command_with_generator ("FALSE_COMMAND"))
			l.extend (command_with_generator ("SIGN_ANALYZER"))

			create l.make (27)
			Result.extend (l, Real_result_command)
			l.extend (command_with_generator ("SUBTRACTION"))
			l.extend (command_with_generator ("MULTIPLICATION"))
			l.extend (command_with_generator ("DIVISION"))
			l.extend (command_with_generator ("SAFE_DIVISION"))
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
			l.extend (command_with_generator ("UNARY_LINEAR_OPERATOR"))
			l.extend (command_with_generator ("ABSOLUTE_VALUE"))
			l.extend (command_with_generator ("N_BASED_UNARY_OPERATOR"))
			l.extend (command_with_generator ("FUNCTION_BASED_COMMAND"))

			create l.make (5)
			Result.extend (l, Binary_real_real_command)
			l.extend (command_with_generator ("SUBTRACTION"))
			l.extend (command_with_generator ("MULTIPLICATION"))
			l.extend (command_with_generator ("DIVISION"))
			l.extend (command_with_generator ("SAFE_DIVISION"))
			l.extend (command_with_generator ("ADDITION"))

			create l.make (6)
			Result.extend (l, Binary_boolean_real_command)
			l.extend (command_with_generator ("LE_OPERATOR"))
			l.extend (command_with_generator ("GE_OPERATOR"))
			l.extend (command_with_generator ("EQ_OPERATOR"))
			l.extend (command_with_generator ("LT_OPERATOR"))
			l.extend (command_with_generator ("GT_OPERATOR"))
			l.extend (command_with_generator ("SIGN_ANALYZER"))

			create l.make (9)
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

			create l.make (9)
			Result.extend (l, Linear_command)
			l.extend (command_with_generator ("UNARY_LINEAR_OPERATOR"))
			l.extend (command_with_generator ("SLOPE_ANALYZER"))
			l.extend (command_with_generator ("SETTABLE_OFFSET_COMMAND"))
			l.extend (command_with_generator ("MINUS_N_COMMAND"))
			l.extend (command_with_generator ("LOWEST_VALUE"))
			l.extend (command_with_generator ("LINEAR_SUM"))
			l.extend (command_with_generator ("HIGHEST_VALUE"))
			l.extend (command_with_generator ("BASIC_LINEAR_COMMAND"))
			l.extend (command_with_generator ("FUNCTION_BASED_COMMAND"))

			create l.make (2)
			Result.extend (l, N_based_calculation)
			l.extend (command_with_generator ("N_VALUE_COMMAND"))
			l.extend (command_with_generator ("MA_EXPONENTIAL"))
			l.extend (command_with_generator ("N_BASED_UNARY_OPERATOR"))

			create l.make (7)
			Result.extend (l, N_record_command)
			l.extend (command_with_generator ("LOWEST_VALUE"))
			l.extend (command_with_generator ("LINEAR_SUM"))
			l.extend (command_with_generator ("HIGHEST_VALUE"))
			l.extend (command_with_generator ("MA_EXPONENTIAL"))
			l.extend (command_with_generator ("N_VALUE_COMMAND"))
			l.extend (command_with_generator ("N_BASED_UNARY_OPERATOR"))
			l.extend (command_with_generator ("MINUS_N_COMMAND"))
		end

feature -- Constants

	Boolean_result_command: STRING is "RESULT_COMMAND [BOOLEAN]"
			-- Name of result command with a BOOLEAN generic parameter

	Real_result_command: STRING is "RESULT_COMMAND [REAL]"
			-- Name of result command with a REAL generic parameter

	Binary_boolean_real_command: STRING is "BINARY_OPERATOR [BOOLEAN, REAL]"
			-- Name of binary command with BOOLEAN, REAL generic parameters

	Binary_real_real_command: STRING is "BINARY_OPERATOR [REAL, REAL]"
			-- Name of binary command with REAL, REAL generic parameters

	Basic_numeric_command: STRING is "BASIC_NUMERIC_COMMAND"
			-- Name of BASIC_NUMERIC_COMMAND

	N_based_calculation: STRING is "N_BASED_CALCULATION"
			-- Name of N_BASED_CALCULATION

	N_record_command: STRING is "N_RECORD_COMMAND"
			-- Name of N_RECORD_COMMAND

	Linear_command: STRING is "LINEAR_COMMAND"
			-- Name of LINEAR_COMMAND

feature -- Status report

	use_market_function_selection: BOOLEAN
			-- Will `market_function_selection' be used to ask the user
			-- for a selection?  If (false or market_tuple_selector is
			-- Void) and market_function is not Void,
			-- `market_function' will be used.

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

	set_market_tuple_selector (arg: MARKET_TUPLE_LIST_SELECTOR) is
			-- Set market_tuple_selector to `arg'.
		require
			arg_not_void: arg /= Void
		do
			market_tuple_selector := arg
		ensure
			market_tuple_selector_set: market_tuple_selector = arg and
				market_tuple_selector /= Void
		end

	set_use_market_function_selection (
				arg: like use_market_function_selection) is
			-- Set use_market_function_selection to `arg'.
		do
			use_market_function_selection := arg
		ensure
			use_market_function_selection:
				use_market_function_selection = arg
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

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
		do
			check
				mf_not_void: market_function /= Void or
					market_tuple_selector /= Void
			end
			if market_tuple_selector /= Void and
				use_market_function_selection or market_function = Void
			then
				Result := market_tuple_selector.market_tuple_list_selection (
							msg)
			else
				Result := market_function.output
			end
		end

	market_function_selection (msg: STRING): MARKET_FUNCTION is
		do
			check
				mf_not_void: market_function /= Void or
					market_tuple_selector /= Void
			end
			if
				market_tuple_selector /= Void and
				use_market_function_selection or market_function = Void
			then
				Result := market_tuple_selector.market_function_selection (
							msg)
			else
				Result := market_function
			end
		end

feature {NONE} -- Implementation

	Binary_boolean,		-- binary operator with boolean result
	Binary_real,		-- binary operator with real result
	Unary_boolean,		-- unary operator with boolean result
	Unary_real,			-- unary operator with real result
	Constant,			-- CONSTANT - needs value to be set
	Other,				-- Classes that need no initialization
	Mtlist_resultreal,  -- Classes that need a market tuple list and a
						-- RESULT_COMMAND [REAL]
	Mtlist_resultreal_n,-- Classes that need a market tuple list, a
						-- RESULT_COMMAND [REAL], and an n-value
	N_command,			-- Classes that (only) need an n-value
	Mtlist,				-- Classes that (only) need a market tuple list
	Resultreal_n,		-- Classes that need a RESULT_COMMAND [REAL] and
						-- an n-value
	Settable_offset,	-- SETTABLE_OFFSET_COMMAND
	Sign_analyzer,		-- SIGN_ANALYZER
	Boolean_num_client,	-- BOOLEAN_NUMERIC_CLIENT
	Function_command    -- FUNCTION_BASED_COMMAND
	:
				INTEGER is unique
			-- Constants identifying initialization routines required for
			-- the different COMMAND types

	initialization_map: HASH_TABLE [INTEGER, STRING] is
			-- Mapping of COMMAND names to initialization classifications
		local
			name: STRING
		once
			create Result.make (0)
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
			name := "NOT_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_boolean, name)
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
			name := "SAFE_DIVISION"
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
			name := "ABSOLUTE_VALUE"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
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
			name := "UNARY_LINEAR_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal, name)
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
			name := "N_BASED_UNARY_OPERATOR"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Resultreal_n, name)
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
			name := "FUNCTION_BASED_COMMAND"
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Function_command, name)
		end

	initialize_command (c: COMMAND) is
			-- Set command parameters - operands, etc.
		local
			const: CONSTANT
			bin_bool_op: BINARY_OPERATOR [ANY, BOOLEAN]
			bin_real_op: BINARY_OPERATOR [ANY, REAL]
			un_bool_op: UNARY_OPERATOR [BOOLEAN, BOOLEAN]
			unop_real: UNARY_OPERATOR [ANY, REAL]
			unop_real_real: UNARY_OPERATOR [REAL, REAL]
			offset_cmd: SETTABLE_OFFSET_COMMAND
			bnc: BOOLEAN_NUMERIC_CLIENT
			sign_an: SIGN_ANALYZER
			fcmd: FUNCTION_BASED_COMMAND
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
					c_is_a_binary_real: bin_real_op /= Void
				end
				editor.edit_binary_real (bin_real_op)
			when Unary_boolean then
				un_bool_op ?= c
				check
					c_is_a_unary_boolean: un_bool_op /= Void
				end
				editor.edit_unary_boolean (un_bool_op)
			when Unary_real then
				unop_real_real ?= c
				check
					c_is_a_unary_real: unop_real_real /= Void
				end
				editor.edit_unaryop_real (unop_real_real)
			when Constant then
				const ?= c
				check
					c_is_a_constant: const /= Void
				end
				editor.edit_constant (const)
			when Mtlist_resultreal then
				unop_real_real ?= c
				check
					c_is_a_unary_operator_real_real: unop_real_real /= Void
				end
				editor.edit_mtlist_resultreal (unop_real_real)
			when Mtlist_resultreal_n then
				unop_real ?= c
				check
					c_is_a_unary_operator_real: unop_real /= Void
				end
				editor.edit_mtlist_resultreal_n (unop_real)
			when Resultreal_n then
				unop_real ?= c
				check
					c_is_a_unary_operator_real: unop_real /= Void
				end
				editor.edit_resultreal_n (unop_real)
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
			when Function_command then
				fcmd ?= c
				check
					c_is_a_function_based_command: fcmd /= Void
				end
				editor.edit_function_based_command (fcmd)
			end
		end

feature -- Implementation

	descendant_reset is
			-- Reset descendant's state.
		do
			left_offset := 0
		end

feature -- Implementation - options

	clone_needed: BOOLEAN is true

	name_needed: BOOLEAN is false

invariant

	clone_needed: clone_needed = true

end -- COMMAND_EDITING_INTERFACE
