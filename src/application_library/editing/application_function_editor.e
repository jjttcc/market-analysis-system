note
	description:
		"Editor of MARKET_FUNCTIONs to be used in a MAL application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class APPLICATION_FUNCTION_EDITOR inherit

	MARKET_FUNCTION_EDITOR
		export
			{NONE} all
		end

	APPLICATION_EDITOR
		redefine
			user_interface
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (ui: FUNCTION_EDITING_INTERFACE; om: COMMAND_EDITING_INTERFACE)
		require
			not_void: ui /= Void and om /= Void
		do
			user_interface := ui
			operator_maker := om
			operator_maker.set_exclude_list (exclude_cmds)
			operator_maker.set_market_tuple_selector (user_interface)
		ensure
			set: user_interface = ui and operator_maker = om
			mts_set: operator_maker.market_tuple_selector = user_interface
		end

feature -- Access

	user_interface: FUNCTION_EDITING_INTERFACE
			-- Interface used to obtain function selections from user

	operator_maker: COMMAND_EDITING_INTERFACE
			-- Interface used to obtain operator selections from user

	last_selected_ovf_input: MARKET_FUNCTION
			-- Last input function chosen in `set_ovf_input'

	last_selected_abf_input: MARKET_FUNCTION
			-- Last input function chosen in `set_abf_input'

	last_selected_left_tvf_input: MARKET_FUNCTION
			-- Last left input function chosen in `set_tvf_input'

	last_selected_right_tvf_input: MARKET_FUNCTION
			-- Last right input function chosen in `set_tvf_input'

feature -- Status setting

	set_operator_maker (arg: COMMAND_EDITING_INTERFACE)
			-- Set operator_maker to `arg'.
		require
			arg_not_void: arg /= Void
		do
			operator_maker := arg
		ensure
			operator_maker_set: operator_maker = arg and
				operator_maker /= Void
		end

feature -- Basic operations

	edit_one_fn_op (f: ONE_VARIABLE_FUNCTION)
			-- Edit a function that takes one market function and an operator.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			set_ovf_input (f)
			operator_maker.reset
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s operator">>), False)
			f.set_operator (cmd)
		end

	edit_accumulation (f: ACCUMULATION)
			-- Edit an accumulation function (which takes a
			-- BINARY_OPERATOR and a LINEAR_COMMAND).
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: BINARY_OPERATOR [REAL, REAL]
			lc: LINEAR_COMMAND
			rc: RESULT_COMMAND [REAL]
		do
			set_ovf_input (f)
			operator_maker.reset
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Binary_real_real_cmd,
							concatenation (<<f.generator,
								"'s main operator">>), False)
			lc ?= operator_maker.command_selection_from_type (
						operator_maker.Linear_cmd,
							concatenation (<<f.generator,
								"'s 'previous' operator">>), False)
			rc ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s first element operator">>), False)
			-- set_operators in ACCUMULATION requires that cmd's left
			-- operand is attached to the same object as lc.
			cmd.set_operands (lc, cmd.operand2)
			check
				lc_set_correctly: cmd.operand1 = lc
			end
			f.set_required_operators (cmd, lc, rc)
		end

	edit_configurable_nrf (f: CONFIGURABLE_N_RECORD_FUNCTION)
			-- Edit a CONFIGURABLE_N_RECORD_FUNCTION function (which takes a
			-- RESULT_COMMAND [REAL] and a LINEAR_COMMAND).
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			mainop: RESULT_COMMAND [REAL]
			prevop: LINEAR_COMMAND
			firstop: RESULT_COMMAND [REAL]
			response: STRING
		do
			set_ovf_input (f)
			operator_maker.reset
			mainop ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s main operator">>), False)
			response := user_interface.string_selection(concatenation(<<
				"Would you like to choose a previous operator for ",
				f.name, "? ">>))
			response.to_lower
			if response @ 1 = 'y' then
				prevop ?= operator_maker.command_selection_from_type (
							operator_maker.Linear_cmd,
								concatenation (<<f.generator,
									"'s 'previous' operator">>), False)
			end
			firstop ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s first element operator">>), False)
			f.set_operators (mainop, prevop, firstop)
			response := user_interface.string_selection(concatenation(<<
				"Would you like to set ", f.name, "'s n-value? ",
				"%N(Note that this may change operator n-values.) ">>))
			response.to_lower
			if response @ 1 = 'y' then
				edit_n (f)
			end
		end

	edit_one_fn_op_n (f: N_RECORD_ONE_VARIABLE_FUNCTION)
			-- Edit a function that takes one market function, an operator,
			-- and an n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			set_ovf_input (f)
			operator_maker.reset
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s operator">>), False)
			f.set_operator (cmd)
			-- Ensure that f's effective offset is set to the absolute
			-- value of the largest left offset (or highest magnitude of
			-- negative offset) used by `cmd' and any members of its
			-- tree - for example, if a SETTABLE_OFFSET_COMMAND occurs
			-- in `cmd's tree and its offset is -3 and there is no smaller
			-- (e.g., -4) offset used by a command in the tree, set f's
			-- effective offset to 3.
			f.set_effective_offset (operator_maker.left_offset)
			edit_n (f)
		end

	edit_two_cplx_fn_op (f: TWO_VARIABLE_FUNCTION)
			-- Edit a function that takes two complex functions
			-- and an operator.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			set_tvf_input (f)
			operator_maker.reset
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s operator">>), False)
			f.set_operator (cmd)
		end

	edit_one_fn_bnc_n (f: STANDARD_MOVING_AVERAGE)
			-- Edit a function that takes one market function,
			-- a RESULT_COMMAND [REAL], and an n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			set_ovf_input (f)
			operator_maker.reset
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s operator">>), False)
			f.set_operator (cmd)
			-- Ensure that f's effective offset is set to the absolute
			-- value of the largest left offset (or highest magnitude of
			-- negative offset) used by `cmd' and any members of its
			-- tree - for example, if a SETTABLE_OFFSET_COMMAND occurs
			-- in `cmd's tree and its offset is -3 and there is no smaller
			-- (e.g., -4) offset used by a command in the tree, set f's
			-- effective offset to 3.
			f.set_effective_offset (operator_maker.left_offset)
			edit_n (f)
		end

	edit_ema (f: EXPONENTIAL_MOVING_AVERAGE)
			-- Edit an EXPONENTIAL_MOVING_AVERAGE - that takes one market
			-- function, a RESULT_COMMAND [REAL], an N_BASED_CALCULATION,
			-- and an n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
			exp: N_BASED_CALCULATION
		do
			set_ovf_input (f)
			operator_maker.reset
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s main operator">>), False)
			f.set_operator (cmd)
			exp ?= operator_maker.command_selection_from_type (
						operator_maker.N_based_calculation,
							concatenation (<<f.generator,
								"'s exponential operator">>), False)
			f.set_exponential (exp)
			-- Ensure that f's effective offset is set to the absolute
			-- value of the largest left offset (or highest magnitude of
			-- negative offset) used by `cmd' and any members of its
			-- tree - for example, if a SETTABLE_OFFSET_COMMAND occurs
			-- in `cmd's tree and its offset is -3 and there is no smaller
			-- (e.g., -4) offset used by a command in the tree, set f's
			-- effective offset to 3.
			f.set_effective_offset (operator_maker.left_offset)
			edit_n (f)
		end

	edit_market_function_line (f: MARKET_FUNCTION_LINE)
			-- Edit a MARKET_FUNCTION_LINE.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			y, slope: REAL
			p: MARKET_POINT
			date: DATE_TIME
		do
			-- It doesn't matter what date is used here.
			create date.make_now
			y := user_interface.real_selection (concatenation (<<
					f.name, "'s starting (leftmost) y value">>))
			slope := user_interface.real_selection (concatenation (<<
					f.name, "'s slope">>))
			create p.make
			p.set_x_y_date (1, y, date)
			f.make (p, slope, user_interface.dummy_tradable)
		end

	edit_agent_based_function (f: AGENT_BASED_FUNCTION)
			-- Edit an AGENT_BASED_FUNCTION.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			set_abf_input (f)
			operator_maker.reset
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_cmd,
							concatenation (<<f.generator,
								"'s operator">>), False)
			f.set_operator (cmd)
		end

	set_ovf_input (f: ONE_VARIABLE_FUNCTION)
			-- Set the input function for the ONE_VARIABLE_FUNCTION `f'.
		do
			last_selected_ovf_input :=
				user_interface.market_function_selection (
				concatenation (<<f.name, "'s (", f.generator,
				") input function">>), Void)
			f.set_input (last_selected_ovf_input)
		end

	set_tvf_input (f: TWO_VARIABLE_FUNCTION)
			-- Set the input functions for the TWO_VARIABLE_FUNCTION `f'.
		local
			i1, i2: COMPLEX_FUNCTION
		do
			i1 ?= user_interface.complex_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") left input function">>))
			i2 ?= user_interface.complex_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") right input function">>))
			f.set_inputs (i1, i2)
			last_selected_left_tvf_input := i1
			last_selected_right_tvf_input := i2
		end

	set_abf_input (f: AGENT_BASED_FUNCTION)
			-- Set the input function for the AGENT_BASED_FUNCTION `f'.
		local
			key_selection: LINKED_LIST [PAIR [STRING, BOOLEAN]]
			keys: LINEAR [STRING]
			key_choices: LIST [STRING]
		do
			last_selected_abf_input :=
				user_interface.market_function_selection (
				concatenation (<<f.name, "'s (", f.generator,
				") input function">>), Void)
			f.clear_inputs
			f.add_input (last_selected_abf_input)
			create key_selection.make
			keys := f.agent_table.keys.linear_representation
			keys.do_all (agent append_string_boolean_pair (key_selection, ?,
				False))
			from until key_choices /= Void and then key_choices.count = 1 loop
				user_interface.choice ("Select a procedure for the %
					%function calculation.", key_selection, 1)
				key_choices := user_interface.choices_from (key_selection)
				if key_choices.count = 0 then
					user_interface.show_message ("Please choose a procedure.")
				end
			end
			f.set_calculator_key (key_choices @ 1)
		end

feature {NONE} -- Implementation

	edit_n (f: ONE_VARIABLE_FUNCTION)
			-- Edit `f's n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			fnctn: N_RECORD_ONE_VARIABLE_FUNCTION
		do
			fnctn ?= f
			check
				f_is_valid_type: fnctn /= Void
			end
			fnctn.set_n (user_interface.integer_selection (
						concatenation (<<fnctn.generator, "'s n-value">>)))
		end

	edit_effective_offset (f: N_RECORD_ONE_VARIABLE_FUNCTION)
			-- Edit `f's effective_offset value.
		local
			response: STRING
		do
			response := user_interface.string_selection(concatenation(<<
				"Change ", f.generator, "'s effective offset value? ",
				"(default: 0) ">>))
			response.to_lower
			if response @ 1 = 'y' then
				f.set_effective_offset (user_interface.integer_selection (
						concatenation (<<f.generator,
							"'s effective offset value">>)))
			end
		end

	exclude_cmds: LIST [COMMAND]
			-- Commands not allowed as operators for market functions
-- !!!! indexing once_status: global??!!!
		once
			create {LINKED_LIST [COMMAND]} Result.make
		end

invariant

	om_not_void: operator_maker /= Void

end -- APPLICATION_FUNCTION_EDITOR
