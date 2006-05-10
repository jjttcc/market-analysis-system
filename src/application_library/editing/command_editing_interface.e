indexing
	description:
		"Abstraction for a user interface that obtains selections needed for %
		%editing of COMMANDs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class COMMAND_EDITING_INTERFACE inherit

	COMMANDS

	OBJECT_EDITING_INTERFACE [COMMAND]
		rename
			object_selection_from_type as command_selection_from_type,
			object_types as command_types, edit_object as edit_command,
			user_object_selection as user_command_selection,
			initialize_object as initialize_command,
			current_objects as current_commands
		redefine
			editor, command_types, descendant_reset, edit_command
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
-- !!!! indexing once_status: global??!!!
		local
			l: ARRAYED_LIST [COMMAND]
		once
			create Result.make (0)
			make_instances

			create l.make (14)
			Result.extend (l, Boolean_result_cmd)
			l.extend (eq_operator)
			l.extend (lt_operator)
			l.extend (gt_operator)
			l.extend (le_operator)
			l.extend (ge_operator)
			l.extend (and_operator)
			l.extend (or_operator)
			l.extend (xor_operator)
			l.extend (implication_operator)
			l.extend (equivalence_operator)
			l.extend (not_operator)
			l.extend (true_command)
			l.extend (false_command)
			l.extend (sign_analyzer)

			create l.make (35)
			Result.extend (l, Real_result_cmd)
			l.extend (basic_numeric_command)
			l.extend (opening_price)
			l.extend (high_price)
			l.extend (low_price)
			l.extend (closing_price)
			l.extend (volume)
			l.extend (open_interest)
			l.extend (basic_linear_command)
			l.extend (unary_linear_operator)
			l.extend (settable_offset_command)
			l.extend (linear_sum)
			l.extend (n_value_command)
			l.extend (n_based_unary_operator)
			l.extend (minus_n_command)
			l.extend (highest_value)
			l.extend (lowest_value)
			l.extend (ma_exponential)
			l.extend (numeric_value_command)
			l.extend (numeric_conditional_command)
			l.extend (numeric_assignment_command)
			l.extend (numeric_valued_command_wrapper)
			l.extend (loop_command)
			l.extend (loop_with_assertions)
			l.extend (value_at_index_command)
			l.extend (index_extractor)
			l.extend (addition)
			l.extend (subtraction)
			l.extend (multiplication)
			l.extend (division)
			l.extend (safe_division)
			l.extend (power)
			l.extend (square_root)
			l.extend (n_th_root)
			l.extend (log_cmd)
			l.extend (log2_cmd)
			l.extend (log10_cmd)
			l.extend (ceiling_cmd)
			l.extend (floor_cmd)
			l.extend (sine_cmd)
			l.extend (cosine_cmd)
			l.extend (tangent_cmd)
			l.extend (arc_sine_cmd)
			l.extend (arc_cosine_cmd)
			l.extend (arc_tangent_cmd)
			l.extend (absolute_value)
			l.extend (rounded_value)
			l.extend (slope_analyzer)
			l.extend (function_based_command)

			create l.make (7)
			Result.extend (l, Binary_real_real_cmd)
			l.extend (addition)
			l.extend (subtraction)
			l.extend (multiplication)
			l.extend (division)
			l.extend (safe_division)
			l.extend (power)
			l.extend (n_th_root)

			create l.make (6)
			Result.extend (l, Binary_boolean_real_cmd)
			l.extend (eq_operator)
			l.extend (lt_operator)
			l.extend (gt_operator)
			l.extend (le_operator)
			l.extend (ge_operator)
			l.extend (sign_analyzer)

			create l.make (7)
			Result.extend (l, Basic_numeric_cmd)
			l.extend (basic_numeric_command)
			l.extend (opening_price)
			l.extend (high_price)
			l.extend (low_price)
			l.extend (closing_price)
			l.extend (volume)
			l.extend (open_interest)

			create l.make (9)
			Result.extend (l, Linear_cmd)
			l.extend (basic_linear_command)
			l.extend (unary_linear_operator)
			l.extend (settable_offset_command)
			l.extend (linear_sum)
			l.extend (highest_value)
			l.extend (lowest_value)
			l.extend (minus_n_command)
			l.extend (value_at_index_command)
			l.extend (slope_analyzer)
			l.extend (function_based_command)

			create l.make (3)
			Result.extend (l, N_based_calculation)
			l.extend (n_value_command)
			l.extend (n_based_unary_operator)
			l.extend (ma_exponential)

			create l.make (7)
			Result.extend (l, N_record_cmd)
			l.extend (highest_value)
			l.extend (lowest_value)
			l.extend (linear_sum)
			l.extend (n_value_command)
			l.extend (n_based_unary_operator)
			l.extend (minus_n_command)
			l.extend (ma_exponential)

			create l.make (3)
			Result.extend (l, Indexed)
			l.extend (highest_value)
			l.extend (lowest_value)
			l.extend (basic_linear_command)
			l.extend (unary_linear_operator)
			l.extend (settable_offset_command)
			l.extend (linear_sum)
			l.extend (minus_n_command)
			l.extend (value_at_index_command)
			l.extend (slope_analyzer)
			l.extend (function_based_command)

			create l.make (1)
			Result.extend (l, Numeric_value_cmd)
			l.extend (numeric_value_command)

			-- Add all commands.
			l := clone (command_instances)
			Result.extend (l, Any_cmd)
		end

feature -- Constants

	Any_cmd: STRING is "[Any Command]"
			-- Name of type of any command

	Boolean_result_cmd: STRING is "RESULT_COMMAND [BOOLEAN]"
			-- Name of result command with a BOOLEAN generic parameter

	Real_result_cmd: STRING is "RESULT_COMMAND [REAL]"
			-- Name of result command with a REAL generic parameter

	Binary_boolean_real_cmd: STRING is "BINARY_OPERATOR [BOOLEAN, REAL]"
			-- Name of binary command with BOOLEAN, REAL generic parameters

	Binary_real_real_cmd: STRING is "BINARY_OPERATOR [REAL, REAL]"
			-- Name of binary command with REAL, REAL generic parameters

	N_based_calculation: STRING is "N_BASED_CALCULATION"
			-- Name of N_BASED_CALCULATION

	N_record_cmd: STRING is "N_RECORD_COMMAND"
			-- Name of N_RECORD_COMMAND

	Linear_cmd: STRING is "LINEAR_COMMAND"
			-- Name of LINEAR_COMMAND

	Indexed: STRING is "INDEXED"
			-- Name of INDEXED

	Basic_numeric_cmd: STRING is
		indexing
			once_status: global
		once
			Result := basic_numeric_command.generator
		end

	Numeric_value_cmd: STRING is
		indexing
			once_status: global
		once
			Result := numeric_value_command.generator
		end

feature -- Status report

	use_market_function_selection: BOOLEAN
			-- Will `market_function_selection' be used to ask the user
			-- for a selection?  If (False or market_tuple_selector is
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
							msg, Void)
			else
				Result := market_function
			end
		end

	name_for (o: COMMAND): STRING is
		do
			Result := ""
			if o.name /= Void and then not o.name.is_empty then
				Result := " (" + o.name + ")"
			end
		end

feature {NONE} -- Implementation

	Binary_boolean,		-- binary operator with boolean result
	Binary_real,		-- binary operator with real result
	Unary_boolean,		-- unary operator with boolean result
	Unary_real,			-- unary operator with real result
	Numeric_value,		-- NUMERIC_VALUE_COMMAND - needs value to be set
	Other,				-- Classes that need no initialization
	Mtlist_resultreal,  -- Classes that need a market tuple list and a
						-- RESULT_COMMAND [REAL]
	Mtlist_resultreal_n,-- Classes that need a market tuple list, a
						-- RESULT_COMMAND [REAL], and an n-value
	Minus_n,			-- MINUS_N_COMMAND
						-- RESULT_COMMAND [REAL], and an n-value
	N_command,			-- Classes that (only) need an n-value
	Mtlist,				-- Classes that (only) need a market tuple list
	Resultreal_n,		-- Classes that need a RESULT_COMMAND [REAL] and
						-- an n-value
	Settable_offset,	-- SETTABLE_OFFSET_COMMAND
	Sign_analyzer_cmd,	-- SIGN_ANALYZER
	Numeric_cond,		-- NUMERIC_CONDITIONAL_COMMAND
	Function_command,   -- FUNCTION_BASED_COMMAND
	Index,				-- INDEX_EXTRACTOR
	Value_at_index,		-- VALUE_AT_INDEX_COMMAND
	Numeric_assignment,	-- NUMERIC_ASSIGNMENT_COMMAND
	Loop_cmd,			-- LOOP_COMMAND
	Numeric_wrapper,	-- NUMERIC_VALUED_COMMAND_WRAPPER
	Cmd_sequence		-- COMMAND_SEQUENCE
	:
				INTEGER is unique
			-- Constants identifying initialization routines required for
			-- the different COMMAND types

	initialization_map: HASH_TABLE [INTEGER, STRING] is
			-- Mapping of COMMAND names to initialization classifications
-- !!!! indexing once_status: global??!!!
		local
			name: STRING
		once
			create Result.make (0)
			name := true_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := false_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := and_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := or_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := xor_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := implication_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := equivalence_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_boolean, name)
			name := not_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_boolean, name)
			name := addition.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := subtraction.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := multiplication.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := power.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := n_th_root.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := division.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := safe_division.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := eq_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := lt_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := gt_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := ge_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := le_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Binary_real, name)
			name := numeric_value_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Numeric_value, name)
			name := absolute_value.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := rounded_value.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := square_root.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := log_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := log2_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := log10_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := ceiling_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := floor_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := sine_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := cosine_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := tangent_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := arc_sine_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := arc_cosine_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := arc_tangent_cmd.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Unary_real, name)
			name := basic_numeric_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := highest_value.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal_n, name)
			name := lowest_value.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal_n, name)
			name := linear_sum.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal_n, name)
			name := minus_n_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Minus_n, name)
			name := unary_linear_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist_resultreal, name)
			name := n_value_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (N_command, name)
			name := ma_exponential.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (N_command, name)
			name := settable_offset_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Settable_offset, name)
			name := volume.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := low_price.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := high_price.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := closing_price.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := opening_price.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := open_interest.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Other, name)
			name := basic_linear_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist, name)
			name := n_based_unary_operator.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Resultreal_n, name)
			name := numeric_conditional_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Numeric_cond, name)
			name := sign_analyzer.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Sign_analyzer_cmd, name)
			name := slope_analyzer.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Mtlist, name)
			name := function_based_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Function_command, name)
			name := index_extractor.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Index, name)
			name := numeric_assignment_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Numeric_assignment, name)
			name := numeric_valued_command_wrapper.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Numeric_wrapper, name)
			name := command_sequence.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Cmd_sequence, name)
			name := loop_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Loop_cmd, name)
			name := loop_with_assertions.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Loop_cmd, name)
			name := value_at_index_command.generator
			check
				valid_name: command_names.has (name)
			end
			Result.extend (Value_at_index, name)
		end

	initialize_command (c: COMMAND) is
			-- Set command parameters - operands, etc.
		local
			nvc: NUMERIC_VALUE_COMMAND
			bin_bool_op: BINARY_OPERATOR [ANY, BOOLEAN]
			bin_real_op: BINARY_OPERATOR [ANY, REAL]
			un_bool_op: UNARY_OPERATOR [BOOLEAN, BOOLEAN]
			unop_real: UNARY_OPERATOR [ANY, REAL]
			unop_real_real: UNARY_OPERATOR [REAL, REAL]
			offset_cmd: SETTABLE_OFFSET_COMMAND
			conditional: NUMERIC_CONDITIONAL_COMMAND
			sign_an: SIGN_ANALYZER
			fcmd: FUNCTION_BASED_COMMAND
			minus_n_cmd: MINUS_N_COMMAND
			ix: INDEX_EXTRACTOR
			mv: NUMERIC_ASSIGNMENT_COMMAND
			nvcw: NUMERIC_VALUED_COMMAND_WRAPPER
			cmd_seq: COMMAND_SEQUENCE
			loopcmd: LOOP_COMMAND
			value_at_idx: VALUE_AT_INDEX_COMMAND
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
			when Numeric_value then
				nvc ?= c
				check
					c_is_a_numeric_value: nvc /= Void
				end
				editor.edit_numeric_value (nvc)
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
			when Minus_n then
				minus_n_cmd ?= c
				check
					c_is_a_minus_n_command: minus_n_cmd /= Void
				end
				editor.edit_minus_n (minus_n_cmd)
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
			when Numeric_cond then
				conditional ?= c
				check
					c_is_a_numeric_conditional_command: conditional /= Void
				end
				editor.edit_numeric_conditional_command (conditional)
			when Sign_analyzer_cmd then
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
			when Index then
				ix ?= c
				check
					c_is_a_function_based_command: ix /= Void
				end
				editor.edit_index_extractor (ix)
			when Numeric_assignment then
				mv ?= c
				check
					c_is_a_numeric_assignment_command: mv /= Void
				end
				editor.edit_numeric_assignment (mv)
			when Numeric_wrapper then
				nvcw ?= c
				check
					c_is_a_numeric_wrapper_command: nvcw /= Void
				end
				editor.edit_numeric_wrapper (nvcw)
			when Cmd_sequence then
				cmd_seq ?= c
				check
					c_is_a_command_sequence: cmd_seq /= Void
				end
				editor.edit_command_sequence (cmd_seq)
			when Loop_cmd then
				loopcmd ?= c
				check
					c_is_a_loop: loopcmd /= Void
				end
				editor.edit_loop_command (loopcmd)
			when Value_at_index then
				value_at_idx ?= c
				check
					c_is_a_value_at_idx: value_at_idx /= Void
				end
				editor.edit_value_at_index_command (value_at_idx)
			end
		end

	edit_command (o: COMMAND; msg: STRING) is
			-- Set `o's name and editable attribute.
		do
			if user_specified_command_name /= Void then
				o.set_name (user_specified_command_name)
			end
			set_editability (o)
		end

feature {NONE} -- Implementation

	descendant_reset is
			-- Reset descendant's state.
		do
			left_offset := 0
		end

	user_specified_command_name: STRING

	editable_state: BOOLEAN

	set_editability (c: COMMAND) is
			-- If `c' is a CONFIGURABLE_EDITABLE_COMMAND set its
			-- editability to `editable_state'.
		local
			editable: CONFIGURABLE_EDITABLE_COMMAND
		do
			editable ?= c
			if editable /= Void then
				editable.set_is_editable (editable_state)
			end
		end

feature {NONE} -- Implementation - options

	clone_needed: BOOLEAN is True

	editing_needed: BOOLEAN

invariant

	clone_needed: clone_needed = True

end -- COMMAND_EDITING_INTERFACE
