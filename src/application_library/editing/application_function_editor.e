indexing
	description:
		"Editor of MARKET_FUNCTIONs to be used in a MAL application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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

	make (ui: FUNCTION_EDITING_INTERFACE; om: COMMAND_EDITING_INTERFACE) is
		require
			not_void: ui /= Void and om /= Void
		do
			user_interface := ui
			operator_maker := om
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

feature -- Status setting

	set_operator_maker (arg: COMMAND_EDITING_INTERFACE) is
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

	edit_one_fn_op (f: ONE_VARIABLE_FUNCTION) is
			-- Edit a function that takes one market function and an operator.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			operator_maker.reset
			f.set_input (user_interface.market_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
							") input function">>)))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
		end

	edit_accumulation (f: ACCUMULATION) is
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
			operator_maker.reset
			f.set_input (user_interface.market_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") input function">>)))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Binary_real_real_command,
							concatenation (<<f.generator,
								"'s main operator">>), false)
			lc ?= operator_maker.command_selection_from_type (
						operator_maker.Linear_command,
							concatenation (<<f.generator,
								"'s 'previous' operator">>), false)
			rc ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s first element operator">>), false)
			-- set_operators in ACCUMULATION requires that cmd's left
			-- operand is attached to the same object as lc.
			cmd.set_operands (lc, cmd.operand2)
			check
				lc_set_correctly: cmd.operand1 = lc
			end
			f.set_operators (cmd, lc, rc)
		end

	edit_one_fn_op_n (f: N_RECORD_ONE_VARIABLE_FUNCTION) is
			-- Edit a function that takes one market function, an operator,
			-- and an n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			operator_maker.reset
			f.set_input (user_interface.market_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") input function">>)))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
			edit_n (f)
			-- Ensure that f's effective offset is set to the absolute
			-- value of the largest left offset (or highest magnitude of
			-- negative offset) used by `cmd' and any members of its
			-- tree - for example, if a SETTABLE_OFFSET_COMMAND occurs
			-- in `cmd's tree and its offset is -3 and there is no smaller
			-- (e.g., -4) offset used by a command in the tree, set f's
			-- effective offset to 3.
			f.set_effective_offset (operator_maker.left_offset)
		end

	edit_two_cplx_fn_op (f: TWO_VARIABLE_FUNCTION) is
			-- Edit a function that takes two complex functions
			-- and an operator.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
			i1, i2: COMPLEX_FUNCTION
		do
			operator_maker.reset
			i1 ?= user_interface.complex_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") left input function">>))
			i2 ?= user_interface.complex_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") right input function">>))
			f.set_inputs (i1, i2)
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
		end

	edit_one_fn_bnc_n (f: STANDARD_MOVING_AVERAGE) is
			-- Edit a function that takes one market function,
			-- a RESULT_COMMAND [REAL], and an n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: RESULT_COMMAND [REAL]
		do
			operator_maker.reset
			f.set_input (user_interface.market_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") input function">>)))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
			edit_n (f)
			-- Ensure that f's effective offset is set to the absolute
			-- value of the largest left offset (or highest magnitude of
			-- negative offset) used by `cmd' and any members of its
			-- tree - for example, if a SETTABLE_OFFSET_COMMAND occurs
			-- in `cmd's tree and its offset is -3 and there is no smaller
			-- (e.g., -4) offset used by a command in the tree, set f's
			-- effective offset to 3.
			f.set_effective_offset (operator_maker.left_offset)
		end

	edit_ema (f: EXPONENTIAL_MOVING_AVERAGE) is
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
			operator_maker.reset
			f.set_input (user_interface.market_function_selection (
							concatenation (<<f.name, "'s (", f.generator,
								") input function">>)))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s main operator">>), false)
			f.set_operator (cmd)
			exp ?= operator_maker.command_selection_from_type (
						operator_maker.N_based_calculation,
							concatenation (<<f.generator,
								"'s exponential operator">>), false)
			f.set_exponential (exp)
			edit_n (f)
			-- Ensure that f's effective offset is set to the absolute
			-- value of the largest left offset (or highest magnitude of
			-- negative offset) used by `cmd' and any members of its
			-- tree - for example, if a SETTABLE_OFFSET_COMMAND occurs
			-- in `cmd's tree and its offset is -3 and there is no smaller
			-- (e.g., -4) offset used by a command in the tree, set f's
			-- effective offset to 3.
			f.set_effective_offset (operator_maker.left_offset)
		end

	edit_market_function_line (f: MARKET_FUNCTION_LINE) is
			-- Edit a MARKET_FUNCTION_LINE.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			y, slope: REAL
			p: MARKET_POINT
			date: DATE_TIME
			per_type_name: STRING
		do
			-- It doesn't matter what date is used here.
			!!date.make_now
			y := user_interface.real_selection (concatenation (<<
					f.name, "'s starting (leftmost) y value">>))
			slope := user_interface.real_selection (concatenation (<<
					f.name, "'s slope">>))
			!!p.make
			p.set_x_y_date (1, y, date)
			f.make (p, slope, period_types @ (period_type_names @ Weekly))
		end

feature {NONE} -- Implementation

	edit_n (f: ONE_VARIABLE_FUNCTION) is
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

	edit_effective_offset (f: N_RECORD_ONE_VARIABLE_FUNCTION) is
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

invariant

	om_not_void: operator_maker /= Void

end -- APPLICATION_FUNCTION_EDITOR
