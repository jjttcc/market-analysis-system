indexing
	description:
		"Abstraction that allows the user to edit, create, and remove %
		%MARKET_FUNCTIONs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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

	STORABLE_SERVICES [MARKET_FUNCTION]
		rename
			real_list as function_library,
			working_list as working_function_library,
			retrieve_persistent_list as force_function_library_retrieval,
			prompt_for_char as character_choice,
			edit_list as edit_indicator_menu
		export
			{NONE} all
			{EDITING_INTERFACE} dirty, readonly, ok_to_save
			{ANY} edit_indicator_menu, changed
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

feature -- Basic operations

feature {APPLICATION_FUNCTION_EDITOR} -- Access

	function_types: HASH_TABLE [ARRAYED_LIST [MARKET_FUNCTION], STRING] is
			-- Hash table of lists of function instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
		local
			l: ARRAYED_LIST [MARKET_FUNCTION]
		once
			create Result.make (0)
			create l.make (8)
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
			create l.make (6)
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

	function_selection (msg: STRING; l: LIST [MARKET_FUNCTION];
				backout_allowed: BOOLEAN): MARKET_FUNCTION is
			-- User-selected MARKET_FUNCTION from the 'l' - if
			-- `backout_allowed', the user is allowed to "back out" -
			-- not choose a function - in which case Result is Void.
		local
			i: INTEGER
		do
			from
				if backout_allowed then
					i := list_selection_with_backout (
						names_from_function_list (l),
						concatenation(<<"Select ", msg>>))
				else
					i := list_selection (names_from_function_list (l),
						concatenation(<<"Select ", msg>>))
				end
				l.start
			until
				i = Exit_value or i = l.index
			loop
				l.forth
			end
			if i /= Exit_value then
				Result := l.item
			end
		end

	market_function_selection (msg: STRING): MARKET_FUNCTION is
			-- User-selected MARKET_FUNCTION from the function library
		local
			l: LINKED_LIST [MARKET_FUNCTION]
			i: INTEGER
		do
			create l.make
			l.append (function_library)
			l.extend (function_with_generator ("STOCK"))
			Result := function_selection (msg, l, false)
		end

	complex_function_selection (msg: STRING): COMPLEX_FUNCTION is
			-- User-selected COMPLEX_FUNCTION from the function library
		local
			l: LIST [COMPLEX_FUNCTION]
			f: COMPLEX_FUNCTION
		do
			-- Select objects from function_library that conform to
			-- COMPLEX_FUNCTION and insert them into l.
			from
				create {LINKED_LIST [COMPLEX_FUNCTION]} l.make
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
			Result := l @ list_selection (names_from_function_list (l),
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

	edit_indicator_list (l: LIST [MARKET_FUNCTION]) is
			-- Editing of indicators in `l'
		require
			not_void: l /= Void
			readonly_or_saveable: readonly or ok_to_save
		local
			selection: INTEGER
			indicator: MARKET_FUNCTION
		do
			from
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := list_selection_with_backout (
					names_from_function_list(l),
					"Select an indicator to edit")
				if selection /= Exit_value then
					indicator := l @ selection
					check indicator /= Void end
					edit_indicator (indicator)
				end
			end
		end

	reset_dirty is
		do
			dirty := false
		ensure
			not_dirty: not dirty
		end

	set_save_state (arg: BOOLEAN) is
			-- Set `ok_to_save' to `arg' and `readonly' to not arg.
		do
			ok_to_save := arg
			readonly := not arg
		ensure
			not_both: not (readonly and ok_to_save)
			ok_to_save_set: ok_to_save = arg
			readonly_if_not_ok_to_save: readonly = not arg
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
			create Result.make (0)
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
			-- slected item of `l'.  No backout is allowed - that is,
			-- the user must select one item in `l' in order to continue.
		deferred
		ensure
			valid: Result >= 1 and Result <= l.count
		end

	list_selection_with_backout (l: LIST [STRING]; msg: STRING): INTEGER is
			-- User's selection from `l' with backout allowed.
		deferred
		ensure
			valid_or_exit: Result >= 1 and Result <= l.count or
				Result = Exit_value
		end

	main_indicator_edit_selection: INTEGER is
			-- User's selection from the indicator editing/creation main menu
		deferred
		end

feature {NONE} -- Implementation

	clone_needed: BOOLEAN is true

	name_needed: BOOLEAN is true

	help: APPLICATION_HELP

	working_function_library: STORABLE_LIST [MARKET_FUNCTION]
			-- List of indicators used for editing until the user saves
			-- the current changes

	set_new_name (o: COMPLEX_FUNCTION; msg: STRING) is
		local
			spiel: ARRAYED_LIST [STRING]
			fnames: LIST [STRING]
		do
			create spiel.make (0)
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
						" that does not match any of the%Nabove names:">>))
			o.set_name (string_selection (concatenation (spiel)))
		end

	reset_error is
		do
			error_occurred := false
		end

	initialize_working_list is
		do
			working_function_library := deep_clone (function_library)
		end

	names_from_function_list (l: LIST [MARKET_FUNCTION]):
				ARRAYED_LIST [STRING] is
			-- Name of each function in `l'
		do
			create Result.make (1)
			from
				l.start
			until
				l.exhausted
			loop
				Result.extend (l.item.name)
				l.forth
			end
		end

	names_from_parameter_list (l: LIST [FUNCTION_PARAMETER];
				desc_type: CHARACTER): ARRAYED_LIST [STRING] is
			-- Name of each function in `l'
			-- If `desc_type' is 's', a short description - the paremeter's
			-- function name - is included; if `desc_type' is 'l', a
			-- long description - the paremeter's function name, current
			-- type, and type description - is included.  Otherwise,
			-- only the name is included.
		local
			desc, value, spaces: STRING
		do
			create Result.make (1)
			from
				l.start
			until
				l.exhausted
			loop
				spaces := "  "
				if desc_type = 'l' then
					desc := l.item.description
					value := concatenation (<<"(value: ",
						l.item.current_value, ", type: ",
						l.item.value_type_description, ")">>)
					if desc.count + value.count > 74 then
						spaces := "%N      "
					end
					Result.extend (concatenation (<<desc, spaces, value>>))
				elseif desc_type = 's' then
					Result.extend (l.item.description)
				else
					Result.extend (l.item.name)
				end
				l.forth
			end
		end

	editable_children (indicator: MARKET_FUNCTION):
				LINKED_LIST [MARKET_FUNCTION] is
			-- Children of `indicator' that have parameters
		local
			c: LIST [MARKET_FUNCTION]
		do
			create Result.make
			c := indicator.children
			from
				c.start
			until
				c.exhausted
			loop
				if not c.item.parameters.empty then
					Result.extend (c.item)
				end
				c.forth
			end
		ensure
			not_void: Result /= Void
		end

feature {NONE} -- Implementation - indicator editing

	do_edit is
			-- Menu for editing indicators in `function_library' - If
			-- the user saves the changes, `function_library' is saved to
			-- persistent store.
		local
			selection: INTEGER
			indicator: MARKET_FUNCTION
		do
			from
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := main_indicator_edit_selection
				inspect
					selection
				when Create_new_value then
					create_new_indicator
				when Edit_value then
					edit_indicator_list (working_function_library)
				when Remove_value then
					remove_indicator
				when Save_value then
					check dirty and ok_to_save end
					save
				when Show_help_value then
					show_message (help @ help.Edit_indicators)
				when Exit_value then
				end
				report_errors
			end
		end

	create_new_indicator is
		local
			f: MARKET_FUNCTION
		do
			f := function_selection_from_type (market_function,
				"root function", true)
			working_function_library.extend (f)
			dirty := true
		end

	remove_indicator is
		local
			indicator: MARKET_FUNCTION
			l: LIST [MARKET_FUNCTION]
			finished: BOOLEAN
		do
			from
				l := working_function_library
				indicator := Void
			until
				finished
			loop
				indicator := function_selection (" to remove", l, true)
				if indicator /= Void then
					inspect character_choice (concatenation (<<"Remove ",
						indicator.name, "? (y[es]/n[o]/q[uit]) ">>), "yYnNqQ")
					when 'y', 'Y' then
						remove_from_working_copy (indicator)
						dirty := true
					when 'n', 'N' then
					when 'q', 'Q' then
						finished := true
					end
				else
					finished := true
				end
			end
		end

	edit_parameter_menu (parameters: LIST [FUNCTION_PARAMETER];
				name: STRING) is
			-- Menu for editing `parameters'
		require
			not_void: parameters /= Void
		local
			selection: INTEGER
			p: FUNCTION_PARAMETER
			query: STRING
			gs: expanded GENERIC_SORTING [FUNCTION_PARAMETER, HASHABLE]
			fpl: LIST [FUNCTION_PARAMETER]
		do
			fpl := gs.sorted_list (parameters)
			from
				selection := Null_value
				if parameters.empty then
					show_message (concatenation (<<"No parameters to edit ",
						"for ", name>>))
					selection := Exit_value
				elseif name /= Void then
					query := concatenation (<<"Select a parameter to edit",
						" for ", name>>)
				else
					query := "Select a parameter to edit"
				end
			until
				selection = Exit_value
			loop
				selection := list_selection_with_backout (
					names_from_parameter_list (fpl, 'l'), query)
				if selection /= Exit_value then
					p := fpl @ selection
					edit_parameter (p)
				end
			end
		end

	edit_parameter (p: FUNCTION_PARAMETER) is
			-- Allow the user to change the value of a function parameter.
		local
			msg, msg2, value: STRING
		do
			msg := concatenation (<<"The current value for:%N", p.description,
				" is ", p.current_value, " - new value?">>)
			from
				value := string_selection (msg)
			until
				p.valid_value (value)
			loop
				msg2 := concatenation (<<value,
					" is not valid, try again%N">>)
				value := string_selection (msg2)
			end
			-- Since a member of the function library is being changed,
			-- it needs to be marked as dirty to ensure it gets saved.
			p.change_value (value)
			dirty := true
			show_message (concatenation (
				<<"New value set to ", p.current_value, "%N">>))
		end

	edit_indicator (i: MARKET_FUNCTION) is
			-- Edit indicator `i'.
		require
			not_void: i /= Void
		local
			has_children_to_edit, has_immediate_parameters: BOOLEAN
			children: LIST [MARKET_FUNCTION]
			quit: BOOLEAN
		do
			children := editable_children (i)
			has_children_to_edit := not children.empty
			has_immediate_parameters := not i.immediate_parameters.empty
			if i.parameters.empty then
				show_message (concatenation (<<"Indicator ", i.name,
					" has no editable parameters.">>))
			elseif
				i.parameters.count = 1 or not duplicates (i.parameters)
			then
				edit_parameter_menu (i.parameters, i.name)
			elseif not has_children_to_edit and has_immediate_parameters then
				edit_parameter_menu (i.immediate_parameters, i.name)
			elseif has_children_to_edit and not has_immediate_parameters then
				show_message (concatenation (<<"Indicator %"", i.name,
					"'s%" children:">>))
				edit_indicator_list (i.children)
			else
				check
					children_and_immediate_params:
						has_children_to_edit and has_immediate_parameters
				end
				from
				until
					quit
				loop
					inspect
						character_choice (concatenation (<<"Indicator ",
							i.name, ":%NEdit children or edit immediate ",
							"parameters? (c[hildren]/i[mmediate]/q[uit]) ">>),
							"cCiIqQ")
					when 'c', 'C' then
						show_message (concatenation (<<"Indicator %"", i.name,
							"'s%" children:">>))
						edit_indicator_list (i.children)
					when 'i', 'I' then
						edit_parameter_menu (i.immediate_parameters, i.name)
					when 'q', 'Q' then
						quit := true
					end
				end
			end
		end

	remove_from_working_copy (f: MARKET_FUNCTION) is
			-- Remove all occurrences of `f' from `working_function_library'.
		local
			l: STORABLE_LIST [MARKET_FUNCTION]
		do
			l := working_function_library
			from
				l.start
			until
				l.exhausted
			loop
				if l.item = f then
					l.remove
				else
					l.forth
				end
			end
		end

	duplicates (parameters: LIST [FUNCTION_PARAMETER]): BOOLEAN is
			-- Are there any items with duplicate names in `parameters'?
		local
			gs: expanded GENERIC_SORTING [STRING, STRING]
		do
			Result := gs.duplicates (
				names_from_parameter_list (parameters, 's'))
		end

invariant

	help_not_void: help /= Void

end -- FUNCTION_EDITING_INTERFACE
