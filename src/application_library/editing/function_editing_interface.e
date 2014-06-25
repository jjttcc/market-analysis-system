note
	description:
		"Abstraction that allows the user to edit, create, and remove %
		%MARKET_FUNCTIONs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class FUNCTION_EDITING_INTERFACE inherit

	MARKET_FUNCTIONS
		export
			{NONE} all
		end

	OBJECT_EDITING_INTERFACE [MARKET_FUNCTION]
		rename
			object_selection_from_type as function_selection_from_type,
			object_types as function_types, edit_object as edit_function,
			user_object_selection as user_function_selection,
			initialize_object as initialize_function,
			current_objects as current_functions
		redefine
			editor, function_types, edit_function
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
		redefine
			synchronize_lists
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

	Market_function: STRING = "MARKET_FUNCTION"
			-- Name of MARKET_FUNCTION

	Complex_function: STRING = "COMPLEX_FUNCTION"
			-- Name of COMPLEX_FUNCTION

feature -- Basic operations

feature -- Access

	function_types: HASH_TABLE [ARRAYED_LIST [MARKET_FUNCTION], STRING]
			-- Hash table of lists of function instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
-- !!!! indexing once_status: global??!!!
		local
			l: ARRAYED_LIST [MARKET_FUNCTION]
		once
			create Result.make (0)
			make_instances

			create l.make (8)
			Result.extend (l, Market_function)
			l.extend (two_variable_function)
			l.extend (one_variable_function)
			l.extend (n_record_one_variable_function)
			l.extend (standard_moving_average)
			l.extend (exponential_moving_average)
			l.extend (accumulation)
			l.extend (configurable_n_record_function)
			l.extend (market_function_line)
			l.extend (agent_based_function)
			l.extend (market_data_function)
			l.extend (stock)

			create l.make (6)
			Result.extend (l, Complex_function)
			l.extend (two_variable_function)
			l.extend (one_variable_function)
			l.extend (n_record_one_variable_function)
			l.extend (standard_moving_average)
			l.extend (exponential_moving_average)
			l.extend (accumulation)
			l.extend (configurable_n_record_function)
			-- @@Added this MARKET_FUNCTION_LINE here on 2003/05/17,
			-- assuming it not being there was an oversight - check this.
			l.extend (market_function_line)
			l.extend (agent_based_function)
			l.extend (market_data_function)
		end

feature {APPLICATION_FUNCTION_EDITOR} -- Access

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE]
		do
			Result := user_function_selection (function_instances, msg).output
		end

	function_selection (msg: STRING; l: LIST [MARKET_FUNCTION];
		backout_allowed: BOOLEAN): MARKET_FUNCTION
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

	function_selection_from_library (msg: STRING): MARKET_FUNCTION
			-- User-selected MARKET_FUNCTION from the function library
		do
			Result := (market_function_selection (msg,
				agent valid_root_function)).twin
			set_complex_function_inputs (Result)
			edit_function (Result, msg)
		end

	market_function_selection (msg: STRING; validity_checker:
		FUNCTION [ANY, TUPLE [MARKET_FUNCTION], BOOLEAN]): MARKET_FUNCTION
			-- User-selected MARKET_FUNCTION from the function library
		local
			l: LINKED_LIST [MARKET_FUNCTION]
		do
			create l.make
			if validity_checker = Void then
				l.append (function_library)
				l.extend (stock)
			else
				from
					function_library.start
				until
					function_library.exhausted
				loop
					if
						validity_checker.item ([function_library.item])
					then
						l.extend (function_library.item)
					end
					function_library.forth
				end
				if
					validity_checker.item ([stock])
				then
					l.extend (stock)
				end
			end
			Result := function_selection (msg, l, False)
		end

	complex_function_selection (msg: STRING): COMPLEX_FUNCTION
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

	dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE]
			-- A tradable to be used as dummy input
		do
			Result ?= function_with_generator ("STOCK")
		ensure
			result_not_void: Result /= Void
		end

feature {EDITING_INTERFACE}

	initialize_function (f: MARKET_FUNCTION)
			-- Set function parameters - operands, etc.
		local
			ema: EXPONENTIAL_MOVING_AVERAGE
			sma: STANDARD_MOVING_AVERAGE
			mfl: MARKET_FUNCTION_LINE
			ovf: ONE_VARIABLE_FUNCTION
			accum: ACCUMULATION
			conf_nrf: CONFIGURABLE_N_RECORD_FUNCTION
			nrovf: N_RECORD_ONE_VARIABLE_FUNCTION
			tvf: TWO_VARIABLE_FUNCTION
			agent_bf: AGENT_BASED_FUNCTION
		do
			inspect
				initialization_map @ f.generator
			when ema_function then
				ema ?= f
				check
					f_is_a_exp_ma: ema /= Void
				end
				editor.edit_ema (ema)
			when One_fn_bnc_n then
				sma ?= f
				check
					f_is_a_ma: sma /= Void
				end
				editor.edit_one_fn_bnc_n (sma)
			when Mkt_fnctn_line then
				mfl ?= f
				check
					f_is_a_line: mfl /= Void
				end
				editor.edit_market_function_line (mfl)
			when One_fn_op_n then
				nrovf ?= f
				check
					f_is_a_n_rec_1vf: nrovf /= Void
				end
				editor.edit_one_fn_op_n (nrovf)
			when One_fn_op then
				ovf ?= f
				check
					f_is_a_1vf: ovf /= Void
				end
				editor.edit_one_fn_op (ovf)
			when Accumulation_key then
				accum ?= f
				check
					f_is_an_accum: accum /= Void
				end
				editor.edit_accumulation (accum)
			when Configurable_nrfn then
				conf_nrf ?= f
				check
					f_is_an_accum: conf_nrf /= Void
				end
				editor.edit_configurable_nrf (conf_nrf)
			when Two_cplx_fn_op then
				tvf ?= f
				check
					f_is_a_2vf: tvf /= Void
				end
				editor.edit_two_cplx_fn_op (tvf)
			when Agent_based_fn then
				agent_bf ?= f
				check
					f_is_an_agent_based_function: agent_bf /= Void
				end
				editor.edit_agent_based_function (agent_bf)
			when Other then
				-- No initialization needed.
			end
		end

	view_indicator_list (l: LIST [MARKET_FUNCTION])
			-- Allow user to view indicators from `l'.
		require
			not_void: l /= Void
		local
			selection: INTEGER
			indicator: MARKET_FUNCTION
			functions: LIST [MARKET_FUNCTION]
			complex_func: COMPLEX_FUNCTION
		do
			from
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := list_selection_with_backout (
					names_from_function_list(l), "Select an indicator to view")
				if selection /= Exit_value then
					indicator := l @ selection
					check indicator /= Void end
					show_message (indicator.node_names)
					-- Display all operator trees for each node in the
					-- function tree.
					from
						functions := indicator.functions
						functions.start
					until
						functions.exhausted
					loop
						complex_func ?= functions.item
						if complex_func /= Void then
							display_operators (complex_func)
						end
						functions.forth
					end
					if
						string_selection (
							"(Hit <Enter> to continue ...)") = "dummy"
					then
					end
				end
			end
		end

--
fooedit_indicator_list (l: LIST [MARKET_FUNCTION])
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
			names_from_function_list(l), "Select an indicator to edit")
		if selection /= Exit_value then
			indicator := l @ selection
			check indicator /= Void end
			edit_indicator (indicator)
		end
	end
end

--

	edit_indicator_list (l: LIST [FUNCTION_PARAMETER])
			-- Editing of indicators in `l'
		require
			not_void: l /= Void
			readonly_or_saveable: readonly or ok_to_save
		local
			selection: INTEGER
			indicator: FUNCTION_PARAMETER
		do
			from
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := list_selection_with_backout (
					names_from_function_list(l), "Select an indicator to edit")
				if selection /= Exit_value then
					indicator := l @ selection
					if attached {MARKET_FUNCTION} indicator as i then
						edit_indicator (i)
					end
				end
			end
		end

	reset_dirty
		do
			dirty := False
		ensure
			not_dirty: not dirty
		end

	set_save_state (arg: BOOLEAN)
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
	Accumulation_key,	-- Takes one market function and two operators.
	One_fn_op_n,		-- Takes one market function, an operator, and an
						-- n-value.
	Two_cplx_fn_op,		-- Takes two complex functions and an operator.
	One_fn_bnc_n,		-- Takes one market function, a BASIC_NUMERIC_COMMAND,
						-- and an n-value.
	ema_function,	    -- EXPONENTIAL_MOVING_AVERAGE function - takes one
						-- market function, a RESULT_COMMAND [REAL],
						-- an N_BASED_CALCULATION, and an n-value.
	Mkt_fnctn_line,		-- a MARKET_FUNCTION_LINE.
	Configurable_nrfn,	-- CONFIGURABLE_N_RECORD_FUNCTION
	Agent_based_fn,		-- AGENT_BASED_FUNCTION
	Other				-- Classes that need no initialization
	:
				INTEGER = unique
			-- Constants identifying initialization routines required for
			-- the different MARKET_FUNCTION types

	initialization_map: HASH_TABLE [INTEGER, STRING]
			-- Mapping of MARKET_FUNCTION names to
			-- initialization classifications
-- !!!! indexing once_status: global??!!!
		local
			name: STRING
		once
			create Result.make (0)
			name := one_variable_function.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (One_fn_op, name)
			name := n_record_one_variable_function.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (One_fn_op_n, name)
			name := two_variable_function.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Two_cplx_fn_op, name)
			name := standard_moving_average.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (One_fn_bnc_n, name)
			name := exponential_moving_average.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (ema_function, name)
			name := accumulation.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Accumulation_key, name)
			name := configurable_n_record_function.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Configurable_nrfn, name)
			name := market_function_line.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Mkt_fnctn_line, name)
			name := market_data_function.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Other, name)
			name := agent_based_function.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Agent_based_fn, name)
			name := stock.generator
			check
				valid_name: function_names.has (name)
			end
			Result.extend (Other, name)
		end

feature {NONE} -- Hook routines

	list_selection (l: LIST [STRING]; msg: STRING): INTEGER
			-- User's selection from `l' - Result is the index of the
			-- slected item of `l'.  No backout is allowed - that is,
			-- the user must select one item in `l' in order to continue.
		deferred
		ensure
			valid: Result >= 1 and Result <= l.count
		end

	list_selection_with_backout (l: LIST [STRING]; msg: STRING): INTEGER
			-- User's selection from `l' with backout allowed.
		deferred
		ensure
			valid_or_exit: Result >= 1 and Result <= l.count or
				Result = Exit_value
		end

	main_indicator_edit_selection: INTEGER
			-- User's selection from the indicator editing/creation main menu
		deferred
		end

feature {NONE} -- Implementation

	clone_needed: BOOLEAN = True

	editing_needed: BOOLEAN = True

	help: APPLICATION_HELP

	working_function_library: STORABLE_LIST [MARKET_FUNCTION]
			-- List of indicators used for editing until the user saves
			-- the current changes

	edit_function (o: MARKET_FUNCTION; msg: STRING)
			-- Set `o's name to value obtained from user.
		local
			spiel: STRING
			fnames: LIST [STRING]
		do
			create spiel.make (0)
			from
				fnames := function_library_names
				fnames.start
			until
				fnames.exhausted
			loop
				spiel.append (fnames.item)
				spiel.append ("%N")
				fnames.forth
			end
			spiel.append ("Choose a name for " + msg +
						" that does not match any of the%Nabove names:")
			o.set_name (visible_string_selection (spiel))
		end

	initialize_working_list
		do
			working_function_library := function_library.deep_twin
		end

	names_from_function_list (l: LIST [FUNCTION_PARAMETER]): ARRAYED_LIST [STRING]
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

	info_from_parameter_list (l: LIST [FUNCTION_PARAMETER];
				desc_type: CHARACTER): ARRAYED_LIST [STRING]
			-- Information from each function parameter in `l'
			-- If `desc_type' is 's', a "short" description - the paremeter's
			-- description - is provided; if `desc_type' is 'l', a
			-- "long" description - the paremeter's description, current
			-- value, and type description - is provided; if `desc_type' is
			-- 'a', "all" information is provided: the "long" description
			-- plus the name.  Otherwise, only the name is provided.
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
				if desc_type = 'l' or desc_type = 'a' then
					desc := l.item.description
					if desc_type = 'a' then
						desc := l.item.name + " - " + desc
					end
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
				LINKED_LIST [MARKET_FUNCTION]
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
				if not c.item.parameters.is_empty then
					Result.extend (c.item)
				end
				c.forth
			end
		ensure
			not_void: Result /= Void
		end

	valid_root_function (f: MARKET_FUNCTION): BOOLEAN
			-- Is `f' allowed to be used as a root function?
		local
			l: LINEAR [MARKET_TUPLE]
			cf: COMPLEX_FUNCTION
			mdf: MARKET_DATA_FUNCTION
		do
			cf ?= f
			mdf ?= f
			if cf /= Void and mdf = Void then
				-- To be a root function `f' is required to be complex, but
				-- not a MARKET_DATA_FUNCTION, since a MARKET_DATA_FUNCTION
				-- (which simply outputs its input) would not be useful 
				-- as a root function.
				Result := True
				l := f.required_tuple_types.linear_representation
				-- `f' is valid only if all of its required tuple types
				-- don't have additional queries (compared to MARKET_TUPLE)
				-- in their interface.  This prevents, for example, a
				-- run-time type error caused by trying to access the
				-- (non-existent) high field of a SIMPLE_TUPLE (which will be
				-- the tuple type of the root function's input).
				from l.start until not Result or l.exhausted loop
					if l.item.has_additional_queries then
						Result := False
					end
					l.forth
				end
			end
		end

	set_complex_function_inputs (f: MARKET_FUNCTION)
		require
			f_is_complex: f.is_complex
		local
			complex_f: COMPLEX_FUNCTION
			l: LINKED_SET [COMPLEX_FUNCTION]
			ovf: ONE_VARIABLE_FUNCTION
			tvf: TWO_VARIABLE_FUNCTION
			abf: AGENT_BASED_FUNCTION
			mfl: MARKET_FUNCTION_LINE
			chosen_functions: LINKED_SET [MARKET_FUNCTION]
			operators: LINKED_SET [COMMAND]
			f_changed: BOOLEAN
			leaf_msg, no_function_msg, it_they_msg: STRING
		do
			create chosen_functions.make
			complex_f ?= f
			check
				f_is_complex: complex_f /= Void
			end
			from
				create l.make
				l.append (complex_f.leaf_functions)
				create operators.make
				no_function_msg := " does not require user-selected input %
					%functions.%N"
				if l.count > 1 then
					leaf_msg := " leaf functions"
					it_they_msg := "they require"
				else
					leaf_msg := " leaf function"
					it_they_msg := "it requires"
				end
				show_message (f.name + " has " + l.count.out + leaf_msg +
					" -%NChecking whether " + it_they_msg + " input %
					%functions to be selected ...")
				l.start
			until
				l.exhausted
			loop
				show_message ("Examining leaf function " + l.item.name + ".%N")
				operators.append (l.item.operators)
				ovf ?= l.item
				if ovf /= Void then
					mfl ?= ovf
					if mfl = Void then
						editor.set_ovf_input (ovf)
						chosen_functions.extend (
							editor.last_selected_ovf_input)
						f_changed := True
					else
						-- l.item is a MARKET_FUNCTION_LINE and does
						-- not need its input function set.
						show_message (l.item.name + no_function_msg)
					end
				else
					tvf ?= l.item
					if tvf /= Void then
						editor.set_tvf_input (tvf)
						chosen_functions.extend (
							editor.last_selected_left_tvf_input)
						chosen_functions.extend (
							editor.last_selected_right_tvf_input)
						f_changed := True
					else
						abf ?= l.item
						if abf /= Void then
							editor.set_abf_input (abf)
							chosen_functions.extend (
								editor.last_selected_abf_input)
							f_changed := True
						else
							-- l.item is a MARKET_DATA_FUNCTION, which does
							-- not need its input function set.
							show_message (l.item.name + no_function_msg)
						end
					end
				end
				l.forth
			end
			if f_changed then
				check
					functions_were_selected: chosen_functions.count > 0
				end
				initialize_linear_commands (chosen_functions, operators,
					complex_f.name)
				-- Setting a new input function for any of f's "descendants"
				-- (in the composite function tree) will cause f's cached
				-- parameter list to become out of date - it needs to be reset.
				complex_f.reset_parameters
			end
		end

	initialize_linear_commands (functions: LIST [MARKET_FUNCTION];
		commands: TRAVERSABLE_SUBSET [COMMAND]; parent_name: STRING)
			-- For each function f in `flist': For each
			-- command c in f.operators, if c is a LINEAR_COMMAND,
			-- initialize c's target from a function, selected by the user,
			-- from `functions'.  `parent_name' is the name of the root
			-- function that owns `flist'.
		require
			at_least_one_function: functions /= Void and then
				functions.count > 0
			parent_name_exists: parent_name /= Void
		local
			f: MARKET_FUNCTION
			lc: LINEAR_COMMAND
			ys: STRING
		do
			ys := "yY"
			if functions.count = 1 then
				f := functions.first
			elseif
				ys.has (character_choice ("Use the same function as input to " +
						parent_name + "'s%Nlinear operators?  (y[es]/n[o]) ",
						"yYnN"))
			then
				f := function_selection ("the function to use for " +
					parent_name + "'s%Nlinear operators", functions, False)
			end
			from
				commands.start
			until
				commands.after
			loop
				lc ?= commands.item
				if lc /= Void then
					if f /= Void then
						lc.set (f.output)
					else
						lc.set (function_selection ("the function to use for %
							%the " + lc.generator + " (" + lc.out +
							") operator's input", functions, False).output)
					end
				end
				commands.forth
			end
		end

	name_for (o: MARKET_FUNCTION): STRING
		do
			Result := ""
		end

	synchronize_lists
		do
			force_function_library_retrieval
		end

	display_operators (indicator: COMPLEX_FUNCTION)
		local
			ops: LIST [COMMAND]
		do
			ops := indicator.direct_operators
			if not ops.is_empty then
				from
					show_message ("operators for " + indicator.name + ":%N")
					ops.start
				until
					ops.exhausted
				loop
					display_operator_tree (ops.item)
					ops.forth
				end
			end
		end

	display_operator_tree (op: COMMAND)
		deferred
		end

feature {NONE} -- Implementation - indicator editing

	do_edit
			-- Menu for editing indicators in `function_library' - If
			-- the user saves the changes, `function_library' is saved to
			-- persistent store.
		local
			selection: INTEGER
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
				when View_value then
					view_indicator_list (working_function_library)
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

	create_new_indicator
		local
			f: MARKET_FUNCTION
		do
			inspect
				character_choice ("Use an existing indicator as the " +
					"root function or use a new object?%N" +
					"(e[xisting]/n[ew]/q[uit]) ", "eEnNqQ")
			when 'e', 'E' then
				f := function_selection_from_library ("the root function")
				dirty := True
			when 'n', 'N' then
				f := function_selection_from_type (market_function,
					"root function", True)
				dirty := True
			when 'q', 'Q' then
			end
			if dirty then
				working_function_library.extend (f)
			end
		end

	remove_indicator
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
				indicator := function_selection (" to remove", l, True)
				if indicator /= Void then
					inspect character_choice (concatenation (<<"Remove ",
						indicator.name, "? (y[es]/n[o]/q[uit]) ">>), "yYnNqQ")
					when 'y', 'Y' then
						remove_from_working_copy (indicator)
						dirty := True
					when 'n', 'N' then
					when 'q', 'Q' then
						finished := True
					end
				else
					finished := True
				end
			end
		end

	edit_parameter_menu (parameters: LIST [FUNCTION_PARAMETER];
				name: STRING)
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
			-- Use a set to discard duplicates:
			fpl := gs.sorted_set (parameters)
			from
				selection := Null_value
				if parameters.is_empty then
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
					info_from_parameter_list (fpl, 'l'), query)
				if selection /= Exit_value then
					p := fpl @ selection
					edit_parameter (p)
				end
			end
		end

	edit_parameter (p: FUNCTION_PARAMETER)
			-- Allow the user to change the value of a function parameter.
		local
			msg, msg2, value: STRING
		do
			msg := concatenation (<<"The current value for:%N", p.description,
				" = ", p.current_value, " - new value?">>)
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
			dirty := True
			show_message (concatenation (
				<<"New value set to ", p.current_value, "%N">>))
		end

	-- (Needed for compiler bug workaround - see note below)
	gensrt: expanded GENERIC_SORTING [FUNCTION_PARAMETER, HASHABLE]

-- @@@WARNING: Due to a bug in the 5.6 compiler, I had to make the following
-- changes to 'edit_indicator' to get rid of code that was triggering the bug
-- (causing a segmentation violation): Replaced all calls to
-- 'edit_parameter_menu' with its implementation.  Then, in order to remove
-- some code duplication, I changed the logic a bit so that the
-- edit_parameter_menu code is only duplicated here twice.  (Before this
-- change, I think it was duplicated three times.)  I also changed the
-- original call to 'duplicates' with its implementation.  After the compiler
-- bug is fixed, these changes need to be undone - calls to edit_parameter_menu
-- put back, etc.  (Use an svn diff between rev. 4335 and rev. 4338 to see
-- what changed.)
	edit_indicator (i: MARKET_FUNCTION)
			-- Edit indicator `i'.
		require
			not_void: i /= Void
		local
			has_children_to_edit, has_immediate_parameters: BOOLEAN
			children: LIST [MARKET_FUNCTION]
			quit: BOOLEAN
			parameters, im_paramaters: LIST [FUNCTION_PARAMETER]
			target_parameters: LIST [FUNCTION_PARAMETER]
			selection: INTEGER
			param: FUNCTION_PARAMETER
			query: STRING
		do
			target_parameters := Void
			children := editable_children (i)
			has_children_to_edit := not children.is_empty
			has_immediate_parameters := not i.immediate_parameters.is_empty
			if attached {LIST [FUNCTION_PARAMETER]} i.parameters as params then
				parameters := gensrt.sorted_set (params)
			end
			im_paramaters := gensrt.sorted_set (i.immediate_parameters)
			if parameters.is_empty then
				show_message ("Indicator " + i.name +
					" has no editable parameters.")
			elseif
				parameters.count = 1 or not gensrt.duplicates (
					info_from_parameter_list (parameters, 's'))
			then
				target_parameters := parameters
			elseif not has_children_to_edit and has_immediate_parameters then
				target_parameters := im_paramaters
			elseif has_children_to_edit and not has_immediate_parameters then
				show_message ("Indicator %"" + i.name + "'s%" children:")
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
						character_choice ("Indicator " + i.name +
							":%NEdit children or edit immediate " +
							"parameters? (c[hildren]/i[mmediate]/q[uit]) ",
							"cCiIqQ")
					when 'c', 'C' then
						show_message ("Indicator %"" + i.name +
							"'s%" children:")
						edit_indicator_list (i.children)
					when 'i', 'I' then
						target_parameters := im_paramaters
						from
							selection := Null_value
							if im_paramaters.is_empty then
								show_message ("No parameters to edit for " +
									i.name)
								selection := Exit_value
							elseif i.name /= Void then
								query := "Select a parameter to edit for " +
									i.name
							else
								query := "Select a parameter to edit"
							end
						until
							selection = Exit_value
						loop
							selection := list_selection_with_backout (
								info_from_parameter_list (target_parameters,
									'l'), query)
							if selection /= Exit_value then
								param := target_parameters @ selection
								edit_parameter (param)
							end
						end
					when 'q', 'Q' then
						quit := True
					end
				end
				target_parameters := Void
			end
			if target_parameters /= Void then
				from
					selection := Null_value
					if target_parameters.is_empty then
						show_message ("No parameters to edit for " + i.name)
						selection := Exit_value
					elseif i.name /= Void then
						query := "Select a parameter to edit for " + i.name
					else
						query := "Select a parameter to edit"
					end
				until
					selection = Exit_value
				loop
					selection := list_selection_with_backout (
						info_from_parameter_list (target_parameters, 'l'),
							query)
					if selection /= Exit_value then
						param := target_parameters @ selection
						edit_parameter (param)
					end
				end
			end
		end

	remove_from_working_copy (f: MARKET_FUNCTION)
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

	duplicates (parameters: LIST [FUNCTION_PARAMETER]): BOOLEAN
			-- Are there any items with duplicate names in `parameters'?
		local
			gs: expanded GENERIC_SORTING [STRING, STRING]
		do
			Result := gs.duplicates (
				info_from_parameter_list (parameters, 's'))
		end

invariant

	help_not_void: help /= Void

end
