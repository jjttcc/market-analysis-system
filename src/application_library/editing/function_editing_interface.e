indexing
	description:
		"Abstraction user interface that obtains selections needed for %
		%editing of MARKET_FUNCTIONs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class FUNCTION_EDITING_INTERFACE inherit

	MARKET_FUNCTIONS
		export
			{NONE} all
		end

	OBJECT_EDITING_INTERFACE [MARKET_FUNCTION]
		rename
			object_selection_from_type as function_selection_from_type,
			object_types as function_types,
			user_object_selection as user_function_selection,
			initialize_object as initialize_function,
			current_objects as current_functions
		redefine
			editor, function_types
		end

feature -- Access

	editor: APPLICATION_FUNCTION_EDITOR
			-- Editor used to set MARKET_FUNCTIONs' operands and parameters

feature -- Constants

	Market_function: STRING is "MARKET_FUNCTION"
			-- Name of MARKET_FUNCTION

	Complex_function: STRING is "COMPLEX_FUNCTION"
			-- Name of COMPLEX_FUNCTION

feature {APPLICATION_FUNCTION_EDITOR} -- Access

	function_types: HASH_TABLE [ARRAYED_LIST [MARKET_FUNCTION], STRING] is
			-- Hash table of lists of function instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
		local
			l: ARRAYED_LIST [MARKET_FUNCTION]
		once
			!!Result.make (0)
			!!l.make (6)
			Result.extend (l, Market_function)
			l.extend (function_with_generator ("TWO_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator (
						"N_RECORD_ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("STANDARD_MOVING_AVERAGE"))
			l.extend (function_with_generator ("EXPONENTIAL_MOVING_AVERAGE"))
			l.extend (function_with_generator ("MARKET_FUNCTION_LINE"))
			!!l.make (5)
			Result.extend (l, Complex_function)
			l.extend (function_with_generator ("TWO_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator (
						"N_RECORD_ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("STANDARD_MOVING_AVERAGE"))
			l.extend (function_with_generator ("EXPONENTIAL_MOVING_AVERAGE"))
		end

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
		do
			--!!!What will go here?
		end

feature {NONE} -- Implementation

	One_fn_op,			-- Takes one market function and an operator.
	One_fn_op_n,		-- Takes one market function, an operator, and an
						-- n-value.
	Two_cplx_fn_op,		-- Takes two complex functions and an operator.
	One_fn_bnc_n,		-- Takes one market function, a BASIC_NUMERIC_COMMAND,
						-- and an n-value.
	One_fn_bnc_nbc_n,	-- Takes one market function, a BASIC_NUMERIC_COMMAND,
						-- an N_BASED_CALCULATION, and an n-value.
	Two_points_pertype	-- Takes two market points and a period type.
	:
				INTEGER is unique
			-- Constants identifying initialization routines required for
			-- the different MARKET_FUNCTION types

	initialization_map: HASH_TABLE [INTEGER, STRING] is
			-- Mapping of MARKET_FUNCTION names to
			-- initialization classifications
		local
			name: STRING
		once
			!!Result.make (0)
			name := "ONE_VARIABLE_FUNCTION"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (One_fn_op, name)
			name := "N_RECORD_ONE_VARIABLE_FUNCTION"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (One_fn_op_n, name)
			name := "TWO_VARIABLE_FUNCTION"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Two_cplx_fn_op, name)
			name := "STANDARD_MOVING_AVERAGE"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (One_fn_bnc_n, name)
			name := "EXPONENTIAL_MOVING_AVERAGE"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (One_fn_bnc_nbc_n, name)
			name := "MARKET_FUNCTION_LINE"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Two_points_pertype, name)
		end

	initialize_function (f: MARKET_FUNCTION) is
			-- Set function parameters - operands, etc.
		local
			ema: EXPONENTIAL_MOVING_AVERAGE
			sma: STANDARD_MOVING_AVERAGE
			mfl: MARKET_FUNCTION_LINE
			ovf: ONE_VARIABLE_FUNCTION
			nrovf: N_RECORD_ONE_VARIABLE_FUNCTION
			tvf: TWO_VARIABLE_FUNCTION
		do
			inspect
				initialization_map @ f.generator
			when One_fn_bnc_nbc_n then
				ema ?= f
				check
					c_is_a_exp_ma: ema /= Void
				end
				editor.edit_one_fn_bnc_nbc_n (ema)
			when One_fn_bnc_n then
				sma ?= f
				check
					c_is_a_ma: sma /= Void
				end
				editor.edit_one_fn_bnc_n (sma)
			when Two_points_pertype then
				mfl ?= f
				check
					c_is_a_line: mfl /= Void
				end
				editor.edit_two_points_pertype (mfl)
			when One_fn_op_n then
				nrovf ?= f
				check
					c_is_a_n_rec_1vf: nrovf /= Void
				end
				editor.edit_one_fn_op_n (nrovf)
			when One_fn_op then
				ovf ?= f
				check
					c_is_a_1vf: ovf /= Void
				end
				editor.edit_one_fn_op (ovf)
			when Two_cplx_fn_op then
				tvf ?= f
				check
					c_is_a_2vf: tvf /= Void
				end
				editor.edit_two_cplx_fn_op (tvf)
			end
		end

feature -- Implementation - options

	initialization_needed: BOOLEAN is true --!!!??

	clone_needed: BOOLEAN is true --!!!??

end -- FUNCTION_EDITING_INTERFACE
