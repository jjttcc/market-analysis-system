indexing
	description:
		"Builder of a list of market event generators"
	note:
		"Hard-coded for testing for now, but may evolve into a legitimate %
		%class"
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

	UI_UTILITIES
		export
			{NONE} all
		end

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		end

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
					%%N     Previous (-) Help (h) ">>)
				inspect
					selected_character
				when 'c', 'C' then
					create_new_event_generator
				when 'r', 'R' then
					remove_event_generator
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

	remove_event_generator is
			-- Allow user to remove a member of
			-- market_event_generation_library.
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
				print_names_in_1_column (names)
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

	create_new_event_generator is
			-- Create a new event generator and add it to 
			-- market_event_generation_library.
		local
			c: CHARACTER
		do
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
			create_event_generator (eg_maker, new_event_type_name)
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
				print_list (<<"Select an event generator for ", msg, ":%N">>)
				print_names_in_1_column (names)
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
			fa_maker.set_operator (operator_choice)
			fa_maker.set_period_type (period_type_choice)
			create_event_generator (fa_maker, new_event_type_name)
		end

	create_new_two_variable_function_analyzer is
			-- Create a new two-variable function analyzer and add it to 
			-- market_event_generation_library.
		local
			c: CHARACTER
			fa_maker: TVFA_FACTORY
		do
			!!fa_maker
			fa_maker.set_functions (
				function_choice_clone ("left technical indicator"),
					function_choice_clone ("right technical indicator"))
			fa_maker.set_period_type (period_type_choice)
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
				fa_maker.set_operator (operator_choice)
			end
			create_event_generator (fa_maker, new_event_type_name)
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
				print_names_in_1_column (names)
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

	operator_choice: RESULT_COMMAND [BOOLEAN] is
		do
			--!!!STUB:
			!TRUE_COMMAND!Result
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
					print_names_in_1_column (names)
					print ("Type a name for the new event that does not match %
							%any of the above names: ")
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
		do
			--Allow the user to choose from period_types.
			--!!!STUB:
			Result := period_types @ (period_type_names @ Daily)
		end

feature {NONE}

	help: HELP

end -- MARKET_EVENT_GENERATOR_BUILDER
