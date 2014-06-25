note
	description:
		"Abstraction that allows the user to edit, build, and remove %
		%market event generators"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class MEG_EDITING_INTERFACE inherit

	GLOBAL_APPLICATION
		export
			{NONE} all
			{ANY} function_library
		end

	EDITING_INTERFACE

	STORABLE_SERVICES [MARKET_EVENT_GENERATOR]
		rename
			real_list as market_event_generation_library,
			working_list as working_meg_library,
			retrieve_persistent_list as force_meg_library_retrieval,
			prompt_for_char as character_choice,
			edit_list as edit_event_generator_menu
		export
			{NONE} all
			{ANY} edit_event_generator_menu, changed
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

feature -- Access

	last_event_generator: MARKET_EVENT_GENERATOR
			-- The last MARKET_EVENT_GENERATOR that was built

feature {NONE} -- Implementation

	do_edit
			-- Menu for editing market event generators
		local
			selection: INTEGER
		do
			from
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := main_menu_selection
				inspect
					selection
				when Create_new_value then
					create_new_event_generator
				when Remove_value then
					remove_event_generator
				when View_value then
					view_event_generator
				when Edit_value then
					edit_event_generator_indicator
				when Save_value then
					save
				when Show_help_value then
					show_message (help @ help.Edit_event_generators)
				else
				end
				report_errors
			end
		end

	remove_event_generator
			-- Allow user to remove a member of
			-- `market_event_generation_library'.
		local
			selection: INTEGER
			meg: MARKET_EVENT_GENERATOR
		do
			from
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := eg_selection (" to remove")
				if selection /= Exit_value then
					meg := working_meg_library @ selection
					inspect
						character_choice (concatenation
							(<<"Remove ", meg.event_type.name,
							"? (y[es]/n[o]/q[uit]) ">>), "yYnNqQ")
					when 'y', 'Y' then
						working_meg_library.start
						working_meg_library.prune (
							working_meg_library @ selection)
						show_message (concatenation (<<"Market analyzer for ",
									meg.event_type.name, " removed.">>))
						dirty := True
					when 'n', 'N' then
					when 'q', 'Q' then
						selection := Exit_value
					end
				end
			end
		end

	view_event_generator
			-- Allow user to view a member of the
			-- `market_event_generation_library'.
		local
			selection: INTEGER
		do
			from
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := eg_selection (" to view")
				if selection /= Exit_value then
					display_event_generator (
						market_event_generation_library @ selection)
				end
			end
		end

	edit_event_generator_indicator
			-- Edit the indicators for elements of the
			-- `market_event_generation_library'.
		local
			selection: INTEGER
		do
			from
				-- Make function_editor read-only and ensure its
				-- edit_indicator_list precondition - readonly because
				-- it will be saved as part of the market event generator
				-- list, not the indicator list.
				function_editor.set_save_state (False)
				selection := Null_value
			until
				selection = Exit_value
			loop
				selection := eg_selection (" to edit")
				if selection /= Exit_value then
					function_editor.edit_indicator_list ((
						working_meg_library @ selection).indicators)
					if not dirty then
						dirty := function_editor.dirty
					end
					function_editor.reset_dirty
				end
			end
		end

	create_new_event_generator
			-- Create a new event generator and add it to 
			-- market_event_generation_library.
		do
			last_event_generator := Void
			inspect
				event_generator_type_selection
			when Simple_eg_type_value then
				create_new_simple_event_generator
			when Compound_eg_type_value then
				create_new_compound_event_generator
			end
			if not error_occurred then
				show_message (concatenation (
					<<last_event_generator.event_type.name, " added.">>))
				dirty := True
			end
		end

	create_new_compound_event_generator
			-- Create a new compound event generator and add it to 
			-- market_event_generation_library.
		local
			eg_maker: COMPOUND_GENERATOR_FACTORY
			left, right: MARKET_EVENT_GENERATOR
		do
			if market_event_generation_library.is_empty then
				show_message ("Can't create compound market analyzer - %
					%persistent analyzer list is empty.")
				error_occurred := True
			else
				create eg_maker.make
				left := event_generator_selection ("left component")
				if left /= Void then
					right := event_generator_selection ("right component")
					eg_maker.set_generators (left, right)
					eg_maker.set_before_extension (
						ceg_date_time_extension ("BEFORE"))
					eg_maker.set_after_extension (ceg_date_time_extension (
						"AFTER"))
					eg_maker.set_left_target_type (ceg_left_target_type)
					if eg_maker.left_target_type /= Void then
						show_message (concatenation (<<
							eg_maker.left_target_type.name, " added.">>))
					end
					eg_maker.set_signal_type (signal_type_selection)
					create_event_generator (eg_maker, new_event_type_name,
						working_meg_library)
					last_event_generator := eg_maker.product
				else
					error_occurred := True
					last_error :=
						"There are no event generators to select from."
				end
			end
		ensure
			-- last_event_generator references the newly created
			-- COMPOUND_EVENT_GENERATOR
		end

	create_new_simple_event_generator
			-- Create a new atomic event generator and add it to 
			-- market_event_generation_library.
		do
			inspect
				one_or_two_market_function_selection
			when One_value then
				create_new_one_variable_function_analyzer
			when Two_value then
				create_new_two_variable_function_analyzer
			end
		end

	create_new_one_variable_function_analyzer
			-- Create a new one-variable function analyzer and add it to 
			-- market_event_generation_library.
		local
			fa_maker: OVFA_FACTORY
		do
			create fa_maker.make
			fa_maker.set_function (
				function_choice_clone ("technical indicator"))
			fa_maker.set_operator (operator_choice (fa_maker.function,
				one_var_exclude_cmds))
			fa_maker.set_period_type (period_type_choice)
			fa_maker.set_left_offset (operator_maker.left_offset)
			fa_maker.set_signal_type (signal_type_selection)
			create_event_generator (fa_maker, new_event_type_name,
				working_meg_library)
			last_event_generator := fa_maker.product
		ensure
			-- last_event_generator references the newly created
			-- ONE_VARIABLE_FUNCTION_ANALYZER
		end

	create_new_two_variable_function_analyzer
			-- Create a new two-variable function analyzer and add it to 
			-- market_event_generation_library.
		local
			fa_maker: TVFA_FACTORY
			op: RESULT_COMMAND [BOOLEAN]
		do
			create fa_maker.make
			fa_maker.set_functions (
				function_choice_clone ("left technical indicator"),
					function_choice_clone ("right technical indicator"))
			fa_maker.set_period_type (period_type_choice)
			fa_maker.set_crossover_specification (above_below_choice (fa_maker))
			op := two_var_function_operator_selection (fa_maker)
			if op /= Void then
				fa_maker.set_operator (op, use_left_function)
			end
			fa_maker.set_signal_type (signal_type_selection)
			create_event_generator (fa_maker, new_event_type_name,
				working_meg_library)
			last_event_generator := fa_maker.product
		ensure
			-- last_event_generator references the newly created
			-- ONE_VARIABLE_FUNCTION_ANALYZER
		end

	function_choice_clone (msg: STRING): MARKET_FUNCTION
			-- A clone of a user-selected member of `function_library'
		do
			Result := (function_choice (msg)).deep_twin
			if editable (Result) then
				function_editor.initialize_function (Result)
			end
		end

	operator_choice (function: MARKET_FUNCTION; exclude_list: LIST [COMMAND]):
				RESULT_COMMAND [BOOLEAN]
			-- User's choice of operator
		do
			operator_maker.set_left_offset (0) -- Important.
			operator_maker.set_market_function (function)
			operator_maker.set_exclude_list (exclude_list)
			Result ?= operator_maker.command_selection_from_type (
						operator_maker.Boolean_result_cmd,
							"root operator", True)
			check
				cmd_selection_valid: Result /= Void
			end
		end

	new_event_type_name: STRING
		local
			names: LIST [STRING]
		do
			--Ask the user for the name of the new event type.
			names := event_type_names.deep_twin
			names.compare_objects
			Result := new_event_type_name_selection (names)
		end

	signal_type_selection: INTEGER
		local
			stypes: SIGNAL_TYPES
			snames: ARRAY [STRING]
			scodes, code_selection_list: STRING
			c: CHARACTER
			i: INTEGER
		do
			create stypes.initialize_signal_type
			snames := stypes.type_names
			scodes := stypes.character_codes
			create code_selection_list.make (0)
			from
				i := 1
			until
				i = scodes.count
			loop
				code_selection_list.extend (scodes @ i)
				code_selection_list.extend ('/')
				i := i + 1
			end
			code_selection_list.extend (scodes @ i)
			c := character_choice (concatenation (<<
				"Select signal type - ", snames @ stypes.Buy_signal,
				", ", snames @ stypes.Sell_signal, ", ",
				snames @ stypes.Neutral_signal, ", ",
				snames @ stypes.Other_signal, " (",
				code_selection_list, ") ">>), scodes)
			Result := scodes.index_of (c, 1)
			check
				valid_selection: scodes.valid_index (Result)
			end
			show_message (concatenation (<<"Signal type set to ",
				stypes.type_names @ Result, ".">>))
		end

feature {NONE} -- Hook methods

	event_generator_selection (msg: STRING): MARKET_EVENT_GENERATOR
			-- User's event generator selection
		require
			meg_library_not_empty: not market_event_generation_library.is_empty
		deferred
		end

	main_menu_selection: INTEGER
			-- User's selection from the MEG-editing main menu
		deferred
		end

	eg_selection (msg_tail: STRING): INTEGER
			-- User's selection of an MEG
		deferred
		end

	event_generator_type_selection: INTEGER
			-- User's selection of MEG type - 
		deferred
		ensure
			valid_result: Result = Simple_eg_type_value or
				Result = Compound_eg_type_value
		end

	one_or_two_market_function_selection: INTEGER
		deferred
		ensure
			valid_result: Result = One_value or Result = Two_value
		end

	period_type_choice: TIME_PERIOD_TYPE
			-- User's choice of trading period type
		deferred
		ensure
			not_void: Result /= Void
		end

	above_below_choice (fa_maker: TVFA_FACTORY): INTEGER
			-- User's choice of whether a 2-variable function analyzer
			-- should look for below-to-above crossovers, above-to-below
			-- crossovers, or both
		deferred
		end

	ceg_date_time_extension (which: STRING): DATE_TIME_DURATION
			-- User's choice (if any) of a date/time extension for a
			-- compound event generator
		deferred
		end

	ceg_left_target_type: EVENT_TYPE
			-- User's choice for the left target type (if any) of a
			-- compound event generator
		deferred
		end

	function_choice (msg: STRING): MARKET_FUNCTION
			-- User's choice of a member of `function_library'
		deferred
		ensure
			Result /= Void
		end

	new_event_type_name_selection (names: LIST [STRING]): STRING
		deferred
		end

	display_event_generator (eg: MARKET_EVENT_GENERATOR)
			-- Print the contents of `eg'.
		deferred
		end

	two_var_function_operator_selection (f: TVFA_FACTORY):
				RESULT_COMMAND [BOOLEAN]
			-- User's selection of an operator for the 2-variable
			-- function analyzer
		deferred
		end

feature {NONE} -- Implementation

	editable (f: MARKET_FUNCTION): BOOLEAN
			-- Is `f' editable in this context?
		local
			line: MARKET_FUNCTION_LINE
		do
			-- Currently it only makes sense to edit MARKET_FUNCTION_LINEs
			-- in the context of market event generator creation/editing.
			line ?= f
			Result := line /= Void
		end

	one_var_exclude_cmds: LIST [COMMAND]
			-- Commands not allowed as operators for one-variable
			-- function analyzers
-- !!!! indexing once_status: global??!!!
		once
			Result := operator_maker.command_types @
				operator_maker.N_record_cmd
		end

	two_var_exclude_cmds: LIST [COMMAND]
			-- Commands not allowed as operators for two-variable
			-- function analyzers
-- !!!! indexing once_status: global??!!!
		once
			create {LINKED_LIST [COMMAND]} Result.make
			Result.append (operator_maker.command_types @
				operator_maker.N_record_cmd)
			Result.append (operator_maker.command_types @
				operator_maker.Linear_cmd)
		end

	initialize_working_list
		do
			working_meg_library := market_event_generation_library.deep_twin
		end

	help: APPLICATION_HELP

	operator_maker: COMMAND_EDITING_INTERFACE

	function_editor: FUNCTION_EDITING_INTERFACE

	working_meg_library: STORABLE_LIST [MARKET_EVENT_GENERATOR]

	use_left_function: BOOLEAN
			-- For a TWO_VARIABLE_FUNCTION_ANALYZER, if it uses an
			-- operator, should it apply the operator to its left or
			-- right function.

	Two_value: INTEGER = 6
	One_value: INTEGER = 7
	Compound_eg_type_value: INTEGER = 8
	Simple_eg_type_value: INTEGER = 9
			-- Menu selection values

invariant

	fields_not_void: operator_maker /= Void and help /= Void and
		function_editor /= Void

end -- MEG_EDITING_INTERFACE
