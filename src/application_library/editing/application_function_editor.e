indexing
	description:
		"Editor of MARKET_FUNCTIONs to be used in a TAL application"
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
			f.set_input (user_interface.function_selection_from_type (
						user_interface.Market_function,
							concatenation (<<f.generator,
								"'s input function">>), false))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
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
			f.set_input (user_interface.function_selection_from_type (
						user_interface.Market_function,
							concatenation (<<f.generator,
								"'s input function">>), false))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
			edit_n (f)
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
			i1 ?= user_interface.function_selection_from_type (
						user_interface.Complex_function,
							concatenation (<<f.generator,
								"'s left input function">>), false)
			f.set_input1 (i1)
			i2 ?= user_interface.function_selection_from_type (
						user_interface.Complex_function,
							concatenation (<<f.generator,
								"'s right input function">>), false)
			f.set_input2 (i2)
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Real_result_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
		end

	edit_one_fn_bnc_n (f: STANDARD_MOVING_AVERAGE) is
			-- Edit a function that takes one market function,
			-- a BASIC_NUMERIC_COMMAND, and an n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: BASIC_NUMERIC_COMMAND
		do
			f.set_input (user_interface.function_selection_from_type (
						user_interface.Market_function,
							concatenation (<<f.generator,
								"'s input function">>), false))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Basic_numeric_command,
							concatenation (<<f.generator,
								"'s operator">>), false)
			f.set_operator (cmd)
			edit_n (f)
		end

	edit_one_fn_bnc_nbc_n (f: EXPONENTIAL_MOVING_AVERAGE) is
			-- Edit a function that takes one market function, a
			-- BASIC_NUMERIC_COMMAND, an N_BASED_CALCULATION, and an n-value.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		local
			cmd: BASIC_NUMERIC_COMMAND
			exp: N_BASED_CALCULATION
		do
			f.set_input (user_interface.function_selection_from_type (
						user_interface.Market_function,
							concatenation (<<f.generator,
								"'s input function">>), false))
			cmd ?= operator_maker.command_selection_from_type (
						operator_maker.Basic_numeric_command,
							concatenation (<<f.generator,
								"'s main operator">>), false)
			f.set_operator (cmd)
			exp ?= operator_maker.command_selection_from_type (
						operator_maker.N_based_calculation,
							concatenation (<<f.generator,
								"'s exponential operator">>), false)
			f.set_exponential (exp)
			edit_n (f)
		end

	edit_two_points_pertype (f: MARKET_FUNCTION_LINE) is
			-- Edit a function that takes two market points and a period type.
		require
			ui_set: user_interface /= Void
			op_maker_set: operator_maker /= Void
		do
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

invariant

	om_not_void: operator_maker /= Void

end -- APPLICATION_FUNCTION_EDITOR
