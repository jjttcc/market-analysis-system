indexing
	description:
		"Abstraction that allows the user to build and remove %
		%market event generators"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MEG_EDITING_INTERFACE inherit

	GLOBAL_APPLICATION
		export
			{NONE} all
			{ANY} function_library
		end

	EDITING_INTERFACE

	GLOBAL_SERVICES
		export
			{NONE} all
		end

feature -- Access

	last_event_generator: MARKET_EVENT_GENERATOR
			-- The last MARKET_EVENT_GENERATOR that was built

feature -- Basic operations

	edit_event_generator_menu is
			-- Menu for editing market event generators
		require
			flib_not_void: function_library /= Void
		local
			selection: INTEGER
		do
			from
				selection := Null_value
			until
				selection = Exit_menu_value
			loop
				selection := main_menu_selection
				inspect
					selection
				when Create_new_eg_value then
					create_new_event_generator
				when Remove_eg_value then
					remove_event_generator
				when View_eg_value then
					view_event_generator
				when Show_help_value then
					show_help (help @ help.Edit_event_generators)
				else
				end
			end
		end

feature {NONE} -- Implementation

	remove_event_generator is
			-- Allow user to remove a member of
			-- `market_event_generation_library'.
		local
			selection: INTEGER
			meg: MARKET_EVENT_GENERATOR
		do
			from
				selection := Null_value
			until
				selection = Exit_menu_value
			loop
				selection := remove_eg_selection
				if selection /= Exit_menu_value then
					meg := market_event_generation_library @ selection
					market_event_generation_library.start
					market_event_generation_library.prune (
						market_event_generation_library @ selection)
					show_message (concatenation (<<"Market analyzer for ",
								meg.event_type.name, " removed.">>))
				end
			end
		end

	view_event_generator is
			-- Allow user to view a member of the
			-- `market_event_generation_library'.
		local
			selection: INTEGER
		do
			from
				selection := Null_value
			until
				selection = Exit_menu_value
			loop
				selection := view_eg_selection
				if selection /= Exit_menu_value then
					display_event_generator (
						market_event_generation_library @ selection)
				end
			end
		end

	create_new_event_generator is
			-- Create a new event generator and add it to 
			-- market_event_generation_library.
		local
			c: CHARACTER
		do
			last_event_generator := Void
			inspect
				event_generator_type_selection
			when Simple_eg_type_value then
				create_new_simple_event_generator
			when Compound_eg_type_value then
				create_new_compound_event_generator
			end
			show_message (concatenation (
						<<last_event_generator.event_type.name, " added.">>))
		end

	create_new_compound_event_generator is
			-- Create a new compound event generator and add it to 
			-- market_event_generation_library.
		local
			eg_maker: COMPOUND_GENERATOR_FACTORY
		do
			!!eg_maker
			eg_maker.set_generators (
				event_generator_selection ("left component"),
				event_generator_selection ("right component"))
			eg_maker.set_before_extension (ceg_date_time_extension ("BEFORE"))
			eg_maker.set_after_extension (ceg_date_time_extension ("AFTER"))
			eg_maker.set_left_target_type (ceg_left_target_type)
			if eg_maker.left_target_type /= Void then
				show_message (concatenation (<<eg_maker.left_target_type.name,
												" added.">>))
			end
			create_event_generator (eg_maker, new_event_type_name)
			last_event_generator := eg_maker.product
		ensure
			-- last_event_generator references the newly created
			-- COMPOUND_EVENT_GENERATOR
		end

	create_new_simple_event_generator is
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

	create_new_one_variable_function_analyzer is
			-- Create a new one-variable function analyzer and add it to 
			-- market_event_generation_library.
		local
			fa_maker: OVFA_FACTORY
		do
			!!fa_maker
			fa_maker.set_function (
				function_choice_clone ("technical indicator"))
			fa_maker.set_operator (operator_choice (fa_maker.function,
				one_var_exclude_cmds))
			fa_maker.set_period_type (period_type_choice)
			fa_maker.set_left_offset (operator_maker.left_offset)
			create_event_generator (fa_maker, new_event_type_name)
			last_event_generator := fa_maker.product
		ensure
			-- last_event_generator references the newly created
			-- ONE_VARIABLE_FUNCTION_ANALYZER
		end

	create_new_two_variable_function_analyzer is
			-- Create a new two-variable function analyzer and add it to 
			-- market_event_generation_library.
		local
			c: CHARACTER
			fa_maker: TVFA_FACTORY
			op: RESULT_COMMAND [BOOLEAN]
		do
			!!fa_maker.make
			fa_maker.set_functions (
				function_choice_clone ("left technical indicator"),
					function_choice_clone ("right technical indicator"))
			fa_maker.set_period_type (period_type_choice)
			fa_maker.set_crossover_specification (above_below_choice (fa_maker))
			op := two_var_function_operator_selection (fa_maker)
			if op /= Void then
				fa_maker.set_operator (op)
			end
			create_event_generator (fa_maker, new_event_type_name)
			last_event_generator := fa_maker.product
		ensure
			-- last_event_generator references the newly created
			-- ONE_VARIABLE_FUNCTION_ANALYZER
		end

	function_choice_clone (msg: STRING): MARKET_FUNCTION is
			-- A clone of a user-selected member of `function_library'
		local
			names: ARRAYED_LIST [STRING]
			s: STRING
		do
			Result := deep_clone (function_choice (msg))
			if editable (Result) then
				function_editor.initialize_function (Result)
			end
		end

	operator_choice (function: MARKET_FUNCTION; exclude_list: LIST [COMMAND]):
				RESULT_COMMAND [BOOLEAN] is
			-- User's choice of operator
		do
			operator_maker.set_left_offset (0) -- Important.
			operator_maker.set_market_function (function)
			operator_maker.set_exclude_list (exclude_list)
			Result ?= operator_maker.command_selection_from_type (
						operator_maker.Boolean_result_command,
							"root operator", true)
			check
				cmd_selection_valid: Result /= Void
			end
		end

	new_event_type_name: STRING is
		local
			names: LIST [STRING]
		do
			--Ask the user for the name of the new event type.
			names := deep_clone (event_type_names)
			names.compare_objects
			Result := new_event_type_name_selection (names)
		end

feature -- Hook methods

	show_help (msg: STRING) is
			-- Display `msg' as help information for the user.
		deferred
		end

	event_generator_selection (msg: STRING): MARKET_EVENT_GENERATOR is
			-- User's event generator selection
		deferred
		end

	main_menu_selection: INTEGER is
			-- User's selection from the MEG-editing main menu
		deferred
		end

	remove_eg_selection: INTEGER is
			-- User's selection of an MEG to be removed from the library
		deferred
		end

	view_eg_selection: INTEGER is
			-- User's selection of an MEG to view
		deferred
		end

	event_generator_type_selection: INTEGER is
			-- User's selection of MEG type - 
		deferred
		ensure
			valid_result: Result = Simple_eg_type_value or
				Result = Compound_eg_type_value
		end

	one_or_two_market_function_selection: INTEGER is
		deferred
		ensure
			valid_result: Result = One_value or Result = Two_value
		end

	period_type_choice: TIME_PERIOD_TYPE is
			-- User's choice of trading period type
		deferred
		ensure
			not_void: Result /= Void
		end

	above_below_choice (fa_maker: TVFA_FACTORY): INTEGER is
			-- User's choice of whether a 2-variable function analyzer
			-- should look for below-to-above crossovers, above-to-below
			-- crossovers, or both
		deferred
		end

	ceg_date_time_extension (which: STRING): DATE_TIME_DURATION is
			-- User's choice (if any) of a date/time extension for a
			-- compound event generator
		deferred
		end

	ceg_left_target_type: EVENT_TYPE is
			-- User's choice for the left target type (if any) of a
			-- compound event generator
		deferred
		end

	function_choice (msg: STRING): MARKET_FUNCTION is
			-- User's choice of a member of `function_library'
		deferred
		end

	new_event_type_name_selection (names: LIST [STRING]): STRING is
		deferred
		end

	display_event_generator (eg: MARKET_EVENT_GENERATOR) is
			-- Print the contents of `eg'.
		deferred
		end

	two_var_function_operator_selection (f: TVFA_FACTORY):
				RESULT_COMMAND [BOOLEAN] is
			-- User's selection of an operator for the 2-variable
			-- function analyzer
		deferred
		end

feature {NONE} -- Implementation

	editable (f: MARKET_FUNCTION): BOOLEAN is
			-- Is `f' editable in this context?
		local
			line: MARKET_FUNCTION_LINE
		do
			-- Currently it only makes sense to edit MARKET_FUNCTION_LINEs
			-- in the context of market event generator creation/editing.
			line ?= f
			Result := line /= Void
		end

	one_var_exclude_cmds: LIST [COMMAND] is
			-- Commands not allowed as operators for one-variable
			-- function analyzers
		once
			Result := operator_maker.command_types @
				operator_maker.N_record_command
		end

	two_var_exclude_cmds: LIST [COMMAND] is
			-- Commands not allowed as operators for two-variable
			-- function analyzers
		once
			!LINKED_LIST [COMMAND]!Result.make
			Result.append (operator_maker.command_types @
				operator_maker.N_record_command)
			Result.append (operator_maker.command_types @
				operator_maker.Linear_command)
			Result.extend (operator_maker.command_with_generator (
				"FUNCTION_BASED_COMMAND"))
		end

	help: HELP

	operator_maker: COMMAND_EDITING_INTERFACE

	function_editor: FUNCTION_EDITING_INTERFACE

	Create_new_eg_value, Remove_eg_value, View_eg_value,
	Show_help_value, Two_value, One_value, Compound_eg_type_value,
	Simple_eg_type_value: INTEGER is unique
			-- Menu selection value

	Exit_menu_value: INTEGER is -1
			-- Value indicating menu is to be exited - negative so as not
			-- to conflict with the unique values or with the numbered
			-- list selections

	Null_value: INTEGER is -2
			-- Value indicating nothing - negative so as not
			-- to conflict with the unique values or with the numbered
			-- list selections

invariant

	fields_not_void: operator_maker /= Void and help /= Void and
		function_editor /= Void

end -- MEG_EDITING_INTERFACE
