indexing
	description:
		"Abstraction user interface that obtains selections needed for %
		%editing of MARKET_FUNCTIONs"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
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
			editor, function_types, set_new_name
		end

	MARKET_TUPLE_LIST_SELECTOR

	GLOBAL_APPLICATION
		rename
			function_names as function_library_names
		export
			{NONE} all
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
			!!l.make (8)
			Result.extend (l, Market_function)
			l.extend (function_with_generator ("TWO_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator (
						"N_RECORD_ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("STANDARD_MOVING_AVERAGE"))
			l.extend (function_with_generator ("EXPONENTIAL_MOVING_AVERAGE"))
			l.extend (function_with_generator ("ACCUMULATION"))
			l.extend (function_with_generator ("MARKET_FUNCTION_LINE"))
			l.extend (function_with_generator ("MARKET_DATA_FUNCTION"))
			l.extend (function_with_generator ("STOCK"))
			!!l.make (6)
			Result.extend (l, Complex_function)
			l.extend (function_with_generator ("TWO_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator (
						"N_RECORD_ONE_VARIABLE_FUNCTION"))
			l.extend (function_with_generator ("STANDARD_MOVING_AVERAGE"))
			l.extend (function_with_generator ("EXPONENTIAL_MOVING_AVERAGE"))
			l.extend (function_with_generator ("ACCUMULATION"))
			l.extend (function_with_generator ("MARKET_DATA_FUNCTION"))
		end

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
		do
			Result := user_function_selection (function_instances, msg).output
		end

	market_function_selection (msg: STRING): MARKET_FUNCTION is
			-- User-selected MARKET_FUNCTION from the function library
		local
			fnames: ARRAYED_LIST [STRING]
			l: LINKED_LIST [MARKET_FUNCTION]
			i: INTEGER
		do
			!!l.make
			l.append (function_library)
			l.extend (function_with_generator ("STOCK"))
			!!fnames.make (1)
			from
				l.start
			until
				l.exhausted
			loop
				fnames.extend (l.item.name)
				l.forth
			end
			from
				i := list_selection (fnames, concatenation(<<"Select ", msg>>))
				l.start
			until
				i = l.index
			loop
				l.forth
			end
			Result := l.item
		end

	complex_function_selection (msg: STRING): COMPLEX_FUNCTION is
			-- User-selected COMPLEX_FUNCTION from the function library
		local
			fnames: ARRAYED_LIST [STRING]
			l: LIST [COMPLEX_FUNCTION]
			f: COMPLEX_FUNCTION
		do
			-- Select objects from function_library that conform to
			-- COMPLEX_FUNCTION and insert them into l.
			from
				!LINKED_LIST [COMPLEX_FUNCTION]!l.make
				function_library.start
			until
				function_library.exhausted
			loop
				f ?= function_library.item
				if f /= Void then
					l.extend (f)
				end
				function_library.forth
			end
			!!fnames.make (l.count)
			from
				l.start
			until
				l.exhausted
			loop
				fnames.extend (l.item.name)
				l.forth
			end
			Result := l @ list_selection (fnames,
						concatenation(<<"Select ", msg>>))
		ensure
			result_not_void: Result /= Void
		end

	dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE] is
			-- A tradable to be used as dummy input
		do
			Result ?= function_with_generator ("STOCK")
		ensure
			result_not_void: Result /= Void
		end

feature {EDITING_INTERFACE}

	initialize_function (f: MARKET_FUNCTION) is
			-- Set function parameters - operands, etc.
		local
			ema: EXPONENTIAL_MOVING_AVERAGE
			sma: STANDARD_MOVING_AVERAGE
			mfl: MARKET_FUNCTION_LINE
			ovf: ONE_VARIABLE_FUNCTION
			accum: ACCUMULATION
			nrovf: N_RECORD_ONE_VARIABLE_FUNCTION
			tvf: TWO_VARIABLE_FUNCTION
		do
			inspect
				initialization_map @ f.generator
			when ema_function then
				ema ?= f
				check
					c_is_a_exp_ma: ema /= Void
				end
				editor.edit_ema (ema)
			when One_fn_bnc_n then
				sma ?= f
				check
					c_is_a_ma: sma /= Void
				end
				editor.edit_one_fn_bnc_n (sma)
			when Mkt_fnctn_line then
				mfl ?= f
				check
					c_is_a_line: mfl /= Void
				end
				editor.edit_market_function_line (mfl)
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
			when Accumulation then
				accum ?= f
				check
					c_is_an_accum: accum /= Void
				end
				editor.edit_accumulation (accum)
			when Two_cplx_fn_op then
				tvf ?= f
				check
					c_is_a_2vf: tvf /= Void
				end
				editor.edit_two_cplx_fn_op (tvf)
			when Other then
				-- No initialization needed.
			end
		end

feature {NONE} -- Implementation

	One_fn_op,			-- Takes one market function and an operator.
	Accumulation,		-- Takes one market function and two operators.
	One_fn_op_n,		-- Takes one market function, an operator, and an
						-- n-value.
	Two_cplx_fn_op,		-- Takes two complex functions and an operator.
	One_fn_bnc_n,		-- Takes one market function, a BASIC_NUMERIC_COMMAND,
						-- and an n-value.
	ema_function,	    -- EXPONENTIAL_MOVING_AVERAGE function - takes one
						-- market function, a RESULT_COMMAND [REAL],
						-- an N_BASED_CALCULATION, and an n-value.
	Mkt_fnctn_line,		-- a MARKET_FUNCTION_LINE.
	Other				-- Classes that need no initialization
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
			Result.extend (ema_function, name)
			name := "ACCUMULATION"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Accumulation, name)
			name := "MARKET_FUNCTION_LINE"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Mkt_fnctn_line, name)
			name := "MARKET_DATA_FUNCTION"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Other, name)
			name := "STOCK"
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Other, name)
		end

feature {NONE} -- Hook routines

	list_selection (l: LIST [STRING]; msg: STRING): INTEGER is
			-- User's selection from `l' - Result is the index of the
			-- slected item of `l'.
		deferred
		end

feature {NONE} -- Implementation

	clone_needed: BOOLEAN is true

	name_needed: BOOLEAN is true

	set_new_name (o: MARKET_FUNCTION; msg: STRING) is
		local
			spiel: ARRAYED_LIST [STRING]
			fnames: LIST [STRING]
		do
			!!spiel.make (0)
			from
				fnames := function_library_names
				fnames.start
			until
				fnames.exhausted
			loop
				spiel.extend (fnames.item)
				spiel.extend ("%N")
				fnames.forth
			end
			spiel.extend (concatenation (<<"Choose a name for ", msg,
						" that does not match any of the%Nabove names">>))
			o.set_name (string_selection (concatenation (spiel)))
		end

end -- FUNCTION_EDITING_INTERFACE
