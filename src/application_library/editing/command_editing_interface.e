indexing
	description:
		"Abstraction user interface that obtains selections needed for %
		%editing of COMMANDs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMMAND_EDITING_INTERFACE inherit

	COMMANDS
		export
			{NONE} all
		end

feature -- Access

	editor: APPLICATION_COMMAND_EDITOR
			-- Editor used to set COMMANDs' operands and parameters

	command_selection (type: STRING; msg: ARRAY [STRING]): COMMAND is
			-- User-selected command whose type conforms to `type'
		require
			type_is_valid: command_types @ type /= Void
		local
			op_names: ARRAYED_LIST [STRING]
			cmd_list: ARRAYED_LIST [COMMAND]
		do
			cmd_list := command_types @ type
			Result := user_command_selection (cmd_list)
			initialize_command (Result)
		ensure
			result_not_void: Result /= Void
		end

		integer_selection (msg: ARRAY [STRING]): INTEGER is
				-- User-selected integer value
			deferred
			end

		market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
				-- User-selected list of market tuples
			deferred
			end

		real_selection (msg: ARRAY [STRING]): REAL is
				-- User-selected real value
			deferred
			end

	command_types: HASH_TABLE [ARRAYED_LIST [COMMAND], STRING] is
			-- Hash table of lists of command instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
		local
			l: ARRAYED_LIST [COMMAND]
		once
			!!Result.make (0)
			!!l.make (12)
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
			!!l.make (19)
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

feature -- Constants

	Boolean_result_command: STRING is "RESULT_COMMAND [BOOLEAN]"
			-- Name of BOOLEAN result command type

	Real_result_command: STRING is "RESULT_COMMAND [REAL]"
			-- Name of REAL result command type

	Basic_numeric_command: STRING is "BASIC_NUMERIC_COMMAND"
			-- Name of BASIC_NUMERIC_COMMAND

feature -- Status setting

	set_editor (arg: APPLICATION_COMMAND_EDITOR) is
			-- Set editor to `arg'.
		require
			arg_not_void: arg /= Void
		do
			editor := arg
		ensure
			editor_set: editor = arg and
				editor /= Void
		end

feature {NONE} -- Implementation

	user_command_selection (cmd_list: ARRAYED_LIST [COMMAND]) is
			-- User's selection of a member of `cmd_list'
		deferred
		end

	Binary_boolean,		-- binary operator with boolean result
	Binary_real,		-- binary operator with real result
	Constant,			-- CONSTANT - needs value to be set
	Other,				-- Classes that need no initialization
	Mtlist_resultreal_n,-- Classes that need a market tuple list, a
						-- RESULT_COMMAND [REAL], and an n-value
	N_command,			-- Classes that need an n-value
	Mtlist,				-- Classes that need a market tuple list
	Settable_offset,	-- the SETTABLE_OFFSET_COMMAND
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
		end

	initialize_command (c: COMMAND) is
			-- Set command parameters - operands, etc.
		do
			inspect
				initialization_map @ c.generator
			when Binary_boolean then
				editor.edit_binary_boolean (c)
			when Binary_real then
				editor.edit_binary_real (c)
			when Constant then
				editor.edit_constant (c)
			when Mtlist_resultreal_n then
				editor.edit_mtlist_resultreal_n (c)
			when Other then
				-- No initialization needed.
			when N_command then
				print ("n-command initialization to be defined ...%N")
			when Mtlist then
				print ("market-tuple-list initialization to be defined ...%N")
			when Settable_offset then
				print ("Settable offset initialization to be defined ...%N")
			when Boolean_num_client then
				print ("boolean-num-client initialization to be defined ...%N")
			end
		end

end -- COMMAND_EDITING_INTERFACE
