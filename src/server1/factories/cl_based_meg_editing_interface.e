indexing
	description:
		"Abstraction that allows the user to build and remove %
		%market event generators"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_EVENT_GENERATOR_BUILDER inherit

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export
			{NONE} all
			{ANY} function_library
		end

	COMMAND_LINE_UTILITIES [MARKET_EVENT_GENERATOR]
		export
			{NONE} all
		end

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (op_maker: COMMAND_EDITING_INTERFACE) is
		require
			arg_not_void: op_maker /= Void
		do
			operator_maker := op_maker
			!!cmd_editor
			operator_maker.set_editor (cmd_editor)
			cmd_editor.set_user_interface (operator_maker)
			!!help.make
		ensure
			opmkr_set: operator_maker = op_maker
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
			finished: BOOLEAN
		do
			from
			until
				finished
			loop
				print_list (<<"Select action:",
					"%N     Create a new market analyzer (c) %
					%Remove a market analyzer (r) %
					%%N     View a market analyzer (v) %
					%Previous (-) Help (h) ">>)
				inspect
					selected_character
				when 'c', 'C' then
					create_new_event_generator
				when 'r', 'R' then
					remove_event_generator
				when 'v', 'V' then
					view_event_generator
				when 'h', 'H' then
					print (help @ help.Edit_event_generators)
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := true
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

feature {NONE} -- Implementation

	remove_event_generator is
			-- Allow user to remove a member of
			-- `market_event_generation_library'.
		local
			names: ARRAYED_LIST [STRING]
			finished: BOOLEAN
			meg_library: LIST [MARKET_EVENT_GENERATOR]
		do
			meg_library := market_event_generation_library
			from
				from
					!!names.make (meg_library.count)
					meg_library.start
				until
					meg_library.exhausted
				loop
					names.extend (
						meg_library.item.event_type.name)
					meg_library.forth
				end
				if names.count = 0 then
					finished := true
					print ("There are currently no market analyzers.%N")
				end
			until
				finished
			loop
				print ("Select a market analyzer to remove (0 to end):%N")
				print_names_in_1_column (names, 1)
				read_integer
				if
					last_integer < 0 or
						last_integer > meg_library.count
				then
					print_list (<<"Selection must be between 0 and ",
								meg_library.count, "%N">>)
				elseif last_integer = 0 then
					finished := true
				else
					check
						valid_index: last_integer > 0 and last_integer <=
							meg_library.count
					end
					meg_library.start
					meg_library.prune (
						meg_library @ last_integer)
					finished := true
				end
			end
		end

	view_event_generator is
			-- Allow user to view a member of the
			-- `market_event_generation_library'.
		local
			names: ARRAYED_LIST [STRING]
			finished: BOOLEAN
			meg_library: LIST [MARKET_EVENT_GENERATOR]
		do
			meg_library := market_event_generation_library
			from
				from
					!!names.make (meg_library.count)
					meg_library.start
				until
					meg_library.exhausted
				loop
					names.extend (
						meg_library.item.event_type.name)
					meg_library.forth
				end
				if names.count = 0 then
					finished := true
					print ("There are currently no market analyzers.%N")
				end
			until
				finished
			loop
				print ("Select a market analyzer to view (0 to end):%N")
				print_names_in_1_column (names, 1)
				read_integer
				if
					last_integer < 0 or
						last_integer > meg_library.count
				then
					print_list (<<"Selection must be between 0 and ",
								meg_library.count, "%N">>)
				elseif last_integer = 0 then
					finished := true
				else
					check
						valid_index: last_integer > 0 and last_integer <=
							meg_library.count
					end
					print_event_generator (meg_library @ last_integer)
					finished := true
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
			from
			until
				c /= '%U'
			loop
				print ("Select analyzer type:  Simple (s) Compound (c) ")
				c := selected_character
				if not (c = 's' or c = 'S' or c = 'c' or c = 'C') then
					c := '%U'
					print_list (<<"Invalid selection: ", c, "%N">>)
				end
			end
			inspect
				c
			when 's', 'S' then
				create_new_simple_event_generator
			when 'c', 'C' then
				create_new_compound_event_generator
			end
			if last_event_generator /= Void then
				print ("New market analyzer created:%N")
				print_event_generator (last_event_generator)
			end
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
			eg_maker.set_before_extension (
				ceg_date_time_extension ("BEFORE"))
			eg_maker.set_after_extension (
				ceg_date_time_extension ("AFTER"))
			eg_maker.set_left_target_type (
				ceg_left_target_type)
			create_event_generator (eg_maker, new_event_type_name)
			last_event_generator := eg_maker.product
		ensure
			-- last_event_generator references the newly created
			-- COMPOUND_EVENT_GENERATOR
		end

	event_generator_selection (msg: STRING): MARKET_EVENT_GENERATOR is
			-- User's event generator selection
		local
			names: ARRAYED_LIST [STRING]
			finished: BOOLEAN
			meg_library: LIST [MARKET_EVENT_GENERATOR]
		do
			meg_library := market_event_generation_library
			from
				from
					!!names.make (meg_library.count)
					meg_library.start
				until
					meg_library.exhausted
				loop
					names.extend (
						meg_library.item.event_type.name)
					meg_library.forth
				end
				if names.count = 0 then
					finished := true
					print ("There are currently no market analyzers.%N")
				end
			until
				finished
			loop
				print_list (<<"Select a market analyzer for ", msg, ":%N">>)
				print_names_in_1_column (names, 1)
				read_integer
				if
					last_integer < 1 or
						last_integer > meg_library.count
				then
					print_list (<<"Selection must be between 1 and ",
								meg_library.count, "%N">>)
				else
					check
						valid_index: last_integer > 0 and last_integer <=
							meg_library.count
					end
					Result := meg_library @ last_integer
					finished := true
				end
			end
		end

	create_new_simple_event_generator is
			-- Create a new atomic event generator and add it to 
			-- market_event_generation_library.
		local
			c: CHARACTER
		do
			from
			until
				c /= '%U'
			loop
				print_list (<<"Would you like this analyzer to use one ",
							"or two technical indicators?%N",
							"     One (o) Two (t) ">>)
				c := selected_character
				if not (c = 'o' or c = 'O' or c = 't' or c = 'T') then
					c := '%U'
					print_list (<<"Invalid selection: ", c, "%N">>)
				end
			end
			inspect
				c
			when 'o', 'O' then
				create_new_one_variable_function_analyzer
			when 't', 'T' then
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
			fa_maker.set_operator (operator_choice (fa_maker.function))
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
		do
			!!fa_maker.make
			fa_maker.set_functions (
				function_choice_clone ("left technical indicator"),
					function_choice_clone ("right technical indicator"))
			fa_maker.set_period_type (period_type_choice)
			fa_maker.set_crossover_specification (above_below_choice (fa_maker))
			from
			until
				c /= '%U'
			loop
				print ("Would you like to define an operator for this %
							%market analyzer? (y/n) ")
				c := selected_character
				if not (c = 'y' or c = 'Y' or c = 'n' or c = 'N') then
					c := '%U'
					print_list (<<"Invalid selection: ", c, "%N">>)
				end
			end
			if c = 'y' or c = 'Y' then
				from
					c := '%U'
				until
					c /= '%U'
				loop
					print_list (<<"Should the operator operate on the left ",
							"function (", fa_maker.left_function.name,
							") or the right function (",
							fa_maker.right_function.name, ")? (l/r) ">>)
					c := selected_character
					if not (c = 'l' or c = 'L' or c = 'r' or c = 'R') then
						c := '%U'
						print_list (<<"Invalid selection: ", c, "%N">>)
					end
				end
				if c = 'l' or c = 'L' then
					fa_maker.set_operator (
						operator_choice (fa_maker.left_function))
				else
					check c = 'r' or c = 'R' end
					fa_maker.set_operator (
						operator_choice (fa_maker.right_function))
				end
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
		do
			from
				!!names.make (function_library.count)
				from
					function_library.start
				until
					function_library.after
				loop
					names.extend (function_library.item.name)
					function_library.forth
				end
			until
				Result /= Void
			loop
				print_list (<<"Select the ", msg,
							":%N">>)
				print_names_in_1_column (names, 1)
				read_integer
				if
					last_integer < 1 or
						last_integer > function_library.count
				then
					print_list (<<"Selection must be between 1 and ",
								function_library.count, "%N">>)
				else
					Result := deep_clone (function_library @ last_integer)
				end
			end
		end

	operator_choice (function: MARKET_FUNCTION): RESULT_COMMAND [BOOLEAN] is
			-- User's choice of operator
		do
			operator_maker.set_left_offset (0) -- Important.
			operator_maker.set_market_function (function)
			Result ?= operator_maker.command_selection_from_type (
						operator_maker.Boolean_result_command,
							"root operator", true)
			check
				cmd_selection_valid: Result /= Void
			end
		end

	new_event_type_name: STRING is
		local
			names: ARRAYED_LIST [STRING]
			etypes: LINEAR [EVENT_TYPE]
		do
			--Ask the user for the name of the new event type.
			!!names.make (event_types.count)
			names.compare_objects
			etypes := event_types.linear_representation
			from
				etypes.start
			until
				etypes.exhausted
			loop
				names.extend (etypes.item.name)
				etypes.forth
			end
			from
			until
				Result /= Void
			loop
				if names.count > 0 then
					print_names_in_1_column (names, 1)
					print ("Type a name for the new event that does not match %
							%any of the above names:%N")
				else
					print ("Type a name for the new event: ")
				end
				read_line
				if names.has (last_string) then
					print_list (<<"%"", last_string, "%" matches one of the %
								%above names, please try again ...%N">>)
				else
					!!Result.make (last_string.count)
					Result.append (last_string)
				end
			end
		end

	period_type_choice: TIME_PERIOD_TYPE is
			-- User's choice of trading period type
		local
			names: LINKED_LIST [STRING]
			i: INTEGER
		do
			from
				i := 1
				!!names.make
			until
				i > period_type_names.count
			loop
				names.extend (period_type_names @ i)
				i := i + 1
			end
			from
			until
				Result /= Void
			loop
				print ("Select the desired trading period type %
						%for the new market analyzer:%N")
				print_names_in_1_column (names, 1)
				read_integer
				if
					last_integer < 1 or
						last_integer > names.count
				then
					print_list (<<"Selection must be between 1 and ",
								names.count, "%N">>)
				else
					Result := period_types @ (names @ last_integer)
				end
			end
			print_list (<<"Using ", Result.name, " period type%N">>)
		end

	above_below_choice (fa_maker: TVFA_FACTORY): INTEGER is
			-- User's choice of whether a 2-variable function analyzer
			-- should look for below-to-above crossovers, above-to-below
			-- crossovers, or both
		do
			from
				Result := -999999999
			until
				Result = fa_maker.Below_to_above or
				Result = fa_maker.Above_to_below or
				Result = fa_maker.Both
			loop
				print ("Select specification for crossover detection:%N%
						%below-to-above (1) above-to-below (2) both (3) ")
				inspect
					selected_character
				when '1' then
					Result := fa_maker.Below_to_above
					print ("Using below-to-above%N")
				when '2' then
					Result := fa_maker.Above_to_below
					print ("Using above-to-below%N")
				when '3' then
					Result := fa_maker.Both
					print ("Using both above-to-below and below-to-above%N")
				else
					print ("Invalid selection%N")
				end
			end
		end

	ceg_date_time_extension (which: STRING): DATE_TIME_DURATION is
			-- User's choice (if any) of a date/time extension for a
			-- compound event generator
		local
			finished, yes: BOOLEAN
			days, months, years: INTEGER
		do
			from
			until
				finished
			loop
				print_list (<<"Would you like to add a time extension ",
					"to match events from the left%Nanalyzer that occur ",
					which, " the right analyzer? (y/n/h) ">>)
				inspect
					selected_character
				when 'y', 'Y' then
					yes := true
					finished := true
				when 'n', 'N' then
					finished := true
				when 'h', 'H' then
					print (help @
						help.Compound_event_generator_time_extensions)
				else
					print ("Invalid response.%N")
				end
			end
			from
				if yes then
					finished := false
				end
			until
				finished
			loop
				print ("Select: days (d) months (m) years (y) End (e) ")
				inspect
					selected_character
				when 'd', 'D' then
					print ("Enter the number of days: ")
					read_integer
					days := last_integer
				when 'm', 'M' then
					print ("Enter the number of months: ")
					read_integer
					months := last_integer
				when 'y', 'Y' then
					print ("Enter the number of years: ")
					read_integer
					years := last_integer
				when 'e', 'E' then
					finished := true
				else
					print ("Invalid response.%N")
				end
				print_list (<<"Current settings: ", days, " days, ",
							months, " months, ", years, " years.%N">>)
			end
			if yes then
				!!Result.make (years, months, days, 0, 0, 0)
				print_list (<<"Duration set to ", Result, ".%N">>)
			end
		end

	ceg_left_target_type: EVENT_TYPE is
			-- User's choice for the left target type (if any) of a
			-- compound event generator
		local
			finished, yes: BOOLEAN
			names: LINKED_LIST [STRING]
			i: INTEGER
		do
			from
			until
				finished
			loop
				print_list (<<"Would you like to specify an event type ",
					"as target for the left analyzer's date/time? ",
					" (y/n/h) ">>)
				inspect
					selected_character
				when 'y', 'Y' then
					yes := true
					finished := true
				when 'n', 'N' then
					finished := true
				when 'h', 'H' then
					print (help @
						help.Compound_event_generator_left_target_type)
				else
					print ("Invalid response.%N")
				end
			end
			from
				if yes then
					finished := false
					from
						!!names.make
						i := 1
					until
						i = event_types.count + 1
					loop
						names.extend ((event_types @ i).name)
						i := i + 1
					end
				end
			until
				finished
			loop
				print ("Select an event type:%N")
				print_names_in_1_column (names, 1)
				read_integer
				if
					last_integer < 1 or
						last_integer > names.count
				then
					print_list (<<"Selection must be between 1 and ",
								names.count, "%N">>)
				else
					Result := event_types @ last_integer
					finished := true
				end
			end
		end

	print_event_generator (eg: MARKET_EVENT_GENERATOR) is
			-- Print the contents of `eg'.
		local
			compound_eg: COMPOUND_EVENT_GENERATOR
			fa: FUNCTION_ANALYZER
			ovfa: ONE_VARIABLE_FUNCTION_ANALYZER
			tvfa: TWO_VARIABLE_FUNCTION_ANALYZER
		do
			print_list (<<"Market analyzer type: ", eg.generator,
				"%NEvent type: ", eg.event_type.name, "%N">>)
			compound_eg ?= eg
			fa ?= eg
			if compound_eg /= Void then
				print ("Left sub-analyzer:%N")
				print_event_generator (compound_eg.left_analyzer)
				print ("Right sub-analyzer:%N")
				print_event_generator (compound_eg.right_analyzer)
			else
				check
					eg_is_fa: fa /= Void
				end
				print_list (<<"has period type ", fa.period_type.name,
							", has start date/time ", fa.start_date_time,
							"%N">>)
				ovfa ?= fa
				tvfa ?= fa
				if ovfa /= Void then
					print_list (<<"Operates on indicator: ",
								ovfa.input.name, "%N">>)
				else
					check
						two_var: tvfa /= Void
					end
					print_list (<<"Operates on two indicators:%N  ",
								tvfa.input1.name, "%N  ",
								tvfa.input2.name, "%N">>)
					print_list (<<"above/below, below/above: ",
							tvfa.above_to_below, ", ", tvfa.below_to_above,
							"%N">>)
				end
				if fa.operator /= Void then
					print ("Uses an operator:%N")
					operator_maker.print_command_tree (fa.operator, 1)
				end
			end
		end

feature {NONE}

	help: HELP
	operator_maker: COMMAND_EDITING_INTERFACE
	cmd_editor: APPLICATION_COMMAND_EDITOR

invariant

	field_not_void: operator_maker /= Void and cmd_editor /= Void and
		help /= Void

end -- MARKET_EVENT_GENERATOR_BUILDER
