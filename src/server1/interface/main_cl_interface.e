indexing
	description: "Top-level application interface - command-line driven"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class MAIN_CL_INTERFACE inherit

	GLOBAL_APPLICATION
		export {NONE}
			all
		undefine
			print
		end

	EXECUTION_ENVIRONMENT
		export {NONE}
			all
		undefine
			print
		end

	COMMAND_LINE_UTILITIES [ANY]
		export
			{NONE} all
		end

	PRINTING
		rename
			output_medium as output_device
		export
			{NONE} all
		undefine
			print
		end

	MAS_EXCEPTION
		export
			{NONE} all
		end

	MAIN_APPLICATION_INTERFACE
		rename
			initialize as mai_initialize, execute as main_menu
		undefine
			print
		redefine
			event_generator_builder, function_builder
		end

creation

	make_io, make

feature -- Initialization

	make (fb: FACTORY_BUILDER) is
		require
			not_void: fb /= Void
		do
			mai_initialize (fb)
			initialize
		end

	make_io (input_dev, output_dev: IO_MEDIUM; fb: FACTORY_BUILDER) is
		require
			not_void: input_dev /= Void and output_dev /= Void and fb /= Void
		do
			mai_initialize (fb)
			initialize
			set_input_device (input_dev)
			set_output_device (output_dev)
		ensure
			iodev_set: input_device = input_dev and output_device = output_dev
		end

feature -- Access

	current_tradable: TRADABLE [BASIC_MARKET_TUPLE]

	current_period_type: TIME_PERIOD_TYPE
			-- Current data period type to be processed

	available_period_types: ARRAYED_LIST [STRING]
			-- List of all period types available for selection

	event_generator_builder: CL_BASED_MEG_EDITING_INTERFACE

	function_builder: CL_BASED_FUNCTION_EDITING_INTERFACE

feature -- Status setting

	set_input_device (arg: IO_MEDIUM) is
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
			event_generator_builder.set_input_device (arg)
			function_builder.set_input_device (arg)
		ensure
			input_device_set: input_device = arg and input_device /= Void
			gen_builder_in_set: event_generator_builder.input_device  = arg
			function_builder_in_set: function_builder.input_device = arg
		end

	set_output_device (arg: IO_MEDIUM) is
			-- Set output_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_device := arg
			event_generator_builder.set_output_device (arg)
			function_builder.set_output_device (arg)
		ensure
			output_device_set: output_device = arg and output_device /= Void
			gen_builder_out_set: event_generator_builder.output_device  = arg
			function_builder_out_set: function_builder.output_device = arg
		end


feature -- Basic operations

	main_menu is
			-- Display the main menu and respond to the user's commands.
		do
			check
				io_devices_not_void: input_device /= Void and
										output_device /= Void
			end
			from
				end_client := False; exit_server := False
			until
				end_client or exit_server
			loop
				print_list (<<"Select action:%N", "     Select market (s) ",
							"View data (v) Edit indicators (e)",
							"%N     Edit market analyzers (m) ",
							"Run market analysis (a)%N",
							"     Set date for market analysis (d) ",
							"Edit event registrants (r)%N",
							"     End client session (x) Help (h) ",
							"Product information (p) ", eom>>)
				inspect
					character_selection (Void)
				when 's', 'S' then
					select_market
				when 'v', 'V' then
					view_menu
				when 'e', 'E' then
					function_builder.edit_indicator_menu (function_library)
				when 'm', 'M' then
					event_generator_builder.edit_event_generator_menu
				when 'r', 'R' then
					registrant_menu
				when 'a', 'A' then
					if event_coordinator.start_date_time = Void then
						print ("%NError: Start date must be set before %
							%running analysis.%N")
					else
						-- Important - update the coordinator with the current
						-- active event generators:
						event_coordinator.set_event_generators (
							active_event_generators)
						event_coordinator.execute
					end
				when 'd', 'D' then
					mkt_analysis_set_date_menu
				when 'x', 'X' then
					end_client := True
				when 'h', 'H' then
					print (help @ help.Main)
				when 'p', 'P' then
					print (product_info)
				when '%/5/' then -- ^E, for exit
					exit_server := True
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
			check
				finished: end_client or exit_server
			end
			-- Notify client that it can terminate:
			print ("")
			io.print ("Cleaning up ...%N")
			-- Ensure that all objects registered for cleanup on termination
			-- are notified of termination.
			if exit_server then
				termination_cleanup
				exit (0)
			else
				print ("(Hit <Enter> to restart the command-line client.)%N")
			end
		rescue
			handle_exception ("main menu")
			if not assertion_violation then
				if not end_client then
					retry
				end
			end
		end

feature {NONE} -- Implementation

	main_edit_indicator_menu is
			-- Menu for editing technical indicators (market functions)
		local
			finished: BOOLEAN
			f: MARKET_FUNCTION
			msg, default_msg, changed_msg: STRING
			work_indicators: LIST [MARKET_FUNCTION]
		do
			from
				default_msg := concatenation (<<"Select action:",
					"%N     Create a new market-data indicator (c) %
					%Remove a market-data indicator (r) %N%
					%     Edit market-data indicators (e) %
					%Exit (x) Previous (-) Help (h) ", eom>>)
				changed_msg := concatenation (<<"Select action:",
					"%N     Create a new market-data indicator (c) %
					%Remove a market-data indicator (r) %N%
					%     Edit market-data indicators (e) %
					%Save changes (s) Exit without saving changes (x) %N%
					%     Previous - abort changes (-) Help (h) ", eom>>)
				msg := default_msg
			until
				finished or end_client
			loop
				dirty := false
				print (msg)
				inspect
					character_selection (Void)
				when 'c', 'C' then
					f := function_builder.function_selection_from_type (
							function_builder.market_function, "root function",
							True)
--!!!Needs to incorporate working library and save/abort option.
					function_library.extend (f)
				when 'r', 'R' then
					if not function_library.empty then
						remove_indicator_menu
					else
						print ("Indicator list is empty - no indicators %
								%to remove.%N")
					end
				when 'e', 'E' then
					if current_tradable = Void then
						print ("Market list is empty - cannot edit indicators %
								%unless at least one market is available.%N")
					elseif current_tradable.indicators.empty then
						print ("Indicator list is empty.%N")
					else
						if work_indicators = Void then
							work_indicators := deep_clone (
								current_tradable.indicators)
						end
						function_builder.edit_indicator_menu (work_indicators)
--edit_indicator_menu (work_indicators)
					end
				when 's', 'S' then
					function_library.copy (working_function_library)
					function_library.save
					working_function_library := deep_clone (function_library)
					current_tradable.indicators.deep_copy (work_indicators)
					msg := default_msg
				when 'x', 'X' then
					end_client := True
				when 'h', 'H' then
					print (help @ help.Edit_indicators)
				when '%/5/' then -- ^E, for exit
					exit_server := True; finished := True
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := True
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
				if function_builder.changed then
					msg := changed_msg
					-- Update working_function_library with changed indicators.
					working_function_library.wipe_out
					working_function_library.append (work_indicators)
					working_function_library.set_dirty
				end
			end
		end

	edit_event_generator_indicator_menu is
--Obsolete!!!
			-- Menu for editing market functions owned by event generators
		local
			analyzer: MARKET_EVENT_GENERATOR
			analyzers: LIST [MARKET_EVENT_GENERATOR]
			finished: BOOLEAN
			names: ARRAYED_LIST [STRING]
		do
			from
				analyzers := market_event_generation_library
				create names.make (analyzers.count)
				from
					analyzers.start
				until
					analyzers.exhausted
				loop
					names.extend (analyzers.item.event_type.name)
					analyzers.forth
				end
			until
				finished
			loop
				print_list (<<"Select a market analyzer to edit ",
							" (0 to end):%N">>)
				print_names_in_1_column (names, 1)
				print (eom)
				read_integer
				if
					last_integer <= -1 or
						last_integer > analyzers.count
				then
					print_list (<<"Selection must be between 0 and ",
								analyzers.count, "%N">>)
				elseif last_integer = 0 then
					finished := True
				else
					analyzer := analyzers @ last_integer
					edit_indicator_menu (analyzer.indicators)
				end
			end
		end

	edit_indicator_menu (indicators: LIST [MARKET_FUNCTION]) is
--Obsolete!!!
		require
			ind_not_void: indicators /= Void
		local
			indicator: MARKET_FUNCTION
			finished: BOOLEAN
		do
			from
			until
				finished
			loop
				print ("Select indicator to edit (0 to end):%N")
				indicator := indicator_selection (indicators)
				if indicator /= Void then
					print_list (<<"Select a parameter for ", indicator.name,
									":%N">>)
					edit_parameter_menu (indicator.parameters)
				else
					finished := True
				end
			end
		end

	edit_parameter_menu (parameters: LIST [FUNCTION_PARAMETER]) is
--Obsolete!!!
		require
			params_not_void: parameters /= Void
		local
			i: INTEGER
			parameter: FUNCTION_PARAMETER
			finished: BOOLEAN
		do
			from
			until
				finished
			loop
				from
					i := 1
					parameters.start
				until
					parameters.after
				loop
					print_list (<<i, ") ", parameters.item.name, " - ",
						parameters.item.function.name,
						" (value: ", parameters.item.current_value, ", type: ",
						parameters.item.value_type_description, ")%N">>)
					parameters.forth
					i := i + 1
				end
				print ("(0 to end) ")
				print (eom)
				read_integer
				if
					last_integer <= -1 or
						last_integer > parameters.count
				then
					print_list (<<"Selection must be between 0 and ",
								parameters.count, "%N">>)
				elseif last_integer = 0 then
					finished := True
				else
					parameter := parameters @ last_integer
					edit_parameter (parameter)
				end
			end
		end

	remove_indicator_menu is
--!!!Move to FUNCTION_EDITING_INTERFACE (?)
--Obsolete!!!
			-- Menu for removing one or more indicators from `function_libary'
		local
			indicator: MARKET_FUNCTION
			finished: BOOLEAN
		do
			from
			until
				finished or function_library.empty
			loop
				print ("Select indicator to remove (0 to end):%N")
				indicator := indicator_selection (function_library)
				if indicator /= Void then
					print_list (<<"Remove ", indicator.name,
						"? (y[es]/n[o]/q[uit]) ", eom>>)
					inspect
						character_selection (Void)
					when 'y', 'Y' then
						remove_indicator (indicator)
					when 'n', 'N' then
					when 'q', 'Q' then
						finished := True
					else
						print ("Invalid selection%N")
					end
				else
					finished := True
				end
				print ("%N%N")
			end
		end

	registrant_menu is
			-- Menu for adding, removing, editing, and viewing event
			-- registrants
		local
			finished: BOOLEAN
			registrar: EVENT_REGISTRATION
		do
			create registrar.make (event_coordinator.dispatcher,
								input_device, output_device)
			from
			until
				finished or end_client
			loop
				print_list (<<"Select action:",
					"%N     Add registrants (a) Remove registrants (r) %
					%View registrants (v) %
					%%N     Edit registrants (e) Exit (x) Previous (-) %
					%Help (h) ", eom>>)
				inspect
					character_selection (Void)
				when 'a', 'A' then
					registrar.add_registrants
				when 'r', 'R' then
					registrar.remove_registrants
				when 'v', 'V' then
					registrar.view_registrants
				when 'e', 'E' then
					registrar.edit_registrants
				when 'x', 'X' then
					end_client := True
				when 'h', 'H' then
					print (help @ help.Edit_event_registrants)
				when '%/5/' then -- ^E, for exit
					exit_server := True; finished := True
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := True
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	view_menu is
			-- Menu for viewing market and market function data
		local
			finished: BOOLEAN
			indicator: MARKET_FUNCTION
		do
			if market_list_handler.empty then
				print ("There are currently no markets to view.%N")
				finished := True
			end
			from
			until
				finished or end_client
			loop
				print_list (<<"Select action for ", current_tradable.symbol,
					":%N     View market data (m) View an indicator (i)%
					% View name (n)%N%
					%     Change data period type [currently ",
					current_period_type.name,
					"] (c)%N     Exit (x) Previous (-) Help (h) ", eom>>)
				inspect
					character_selection (Void)
				when 'm', 'M' then
					print_tuples (current_tradable.tuple_list (
									current_period_type.name))
				when 'c', 'C' then
					select_period_type
				when 'i', 'I' then
					print ("Select indicator to view (0 to end):%N")
					indicator := indicator_selection
									(current_tradable.indicators)
					if indicator /= Void then
						view_indicator_menu (indicator)
					end
				when 'n', 'N' then
					print_list (<<"%N", current_tradable.name>>)
				when 'x', 'X' then
					end_client := True
				when 'h', 'H' then
					print (help @ help.View_data)
				when '%/5/' then -- ^E, for exit
					exit_server := True; finished := True
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := True
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	mkt_analysis_set_date_menu is
			-- Obtain the date and time to begin market analysis from the
			-- user and pass it to the event generators.
		local
		do
			event_coordinator.set_start_date_time (date_time_selection (
				"%NPlease selecte a date and time for market analysis."))
		end

	view_indicator_menu (indicator: MARKET_FUNCTION) is
			-- Menu for viewing market function data
		local
			finished: BOOLEAN
		do
			from
			until
				finished or end_client
			loop
				print_list (<<"Select action:%N%
						%     Print indicator (p) View description (d) %N%
						%     View long description (l) Exit (x) Previous (-) %
						% Help (h) ", eom>>)
				inspect
					character_selection (Void)
				when 'p', 'P' then
					if not indicator.processed then
						print_list (<<"Processing ", indicator.name, " ...%N">>)
						indicator.process
					end
					print_indicator (indicator)
				when 'd', 'D' then
					print (indicator.short_description)
				when 'l', 'L' then
					print (indicator.full_description)
				when 'x', 'X' then
					end_client := True
				when 'h', 'H' then
					print (help @ help.View_indicator)
				when '%/5/' then -- ^E, for exit
					exit_server := True; finished := True
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := True
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	select_market is
			-- Allow the user to select the current market so that
			-- market_list_handler.item (current_period_type) is the
			-- selected market.
		local
			symbol: STRING
			symbols: LIST [STRING]
			old_tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			old_tradable := current_tradable
			if not market_list_handler.empty then
				from
					symbols := market_list_handler.symbols
				until
					symbol /= Void
				loop
					print_names_in_4_columns (symbols)
					print (eom)
					read_integer
					if
						last_integer <= 0 or
							last_integer > symbols.count
					then
						print_list (<<"Selection must be between 1 and ",
									symbols.count, "%N">>)
					else
						symbol := symbols @ last_integer
					end
				end
				check
					symbol_in_list: market_list_handler.symbols.has (symbol)
				end
				current_tradable := market_list_handler.tradable (symbol,
					current_period_type)
				if market_list_handler.error_occurred then
					log_errors (<<"Error occurred while retreiving data for ",
						symbol, ": ", market_list_handler.last_error, ".%N">>)
				else
					-- Update the current_tradable's target period type,
					-- if needed.
					if
						current_tradable.target_period_type /=
							current_period_type
					then
						current_tradable.set_target_period_type (
							current_period_type)
					end
				end
			else
				print ("There are no markets available to select from.%N")
			end
		end

	select_period_type is
			-- Obtain selection for current_period_type from user and set
			-- the current tradable's target_period_type to it.
		local
			i: INTEGER
			types: ARRAY [STRING]
			per_type_choice: TIME_PERIOD_TYPE
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
			if not market_list_handler.empty then
				from
					i := 1
					types := available_period_types
				until
					i > types.count
				loop
					print_list (<<i, ") ", types @ i, "%N">>)
					i := i + 1
				end
				from
					print (eom)
					read_integer
				until
					last_integer > 0 and last_integer <= types.count
				loop
					print_list (<<"Selection must be between 1 and ",
								types.count, " - try again: %N">>)
					print (eom)
					read_integer
				end
				per_type_choice := period_types @ (types @ last_integer)
				t := current_tradable
				if
					not t.valid_period_type (per_type_choice)
				then
					-- Set `t' to the appropriate tradable according to
					-- `per_type_choice', intraday or non-intraday.
					t := market_list_handler.tradable (t.symbol,
						per_type_choice)
				end
				if t = Void then
					print_list (<<"The chosen period type of ",
						per_type_choice.name, " is not valid.%N">>)
				else
					current_period_type := per_type_choice
					current_tradable := t
					print_list (<<"Data period type set to ",
								current_period_type.name, "%N">>)
					current_tradable.set_target_period_type (
						current_period_type)
				end
			else
				print ("There are no markets to select a period type for.%N")
			end
		end

	indicator_selection (indicators: LIST [MARKET_FUNCTION]):
				MARKET_FUNCTION is
			-- User-selected indicator by number - Void if user chooses 0
		require
			not_void_or_empty: indicators /= Void and not indicators.empty
		local
			names: ARRAYED_LIST [STRING]
			finished: BOOLEAN
		do
			from
				create names.make (indicators.count)
				from
					indicators.start
				until
					indicators.exhausted
				loop
					names.extend (indicators.item.name)
					indicators.forth
				end
			until
				finished
			loop
				print_names_in_1_column (names, 1)
				print (eom)
				read_integer
				if
					last_integer < 0 or
						last_integer > indicators.count
				then
					print_list (<<"Selection must be between 0 and ",
								indicators.count, "%N">>)
				else
					finished := True
					if last_integer /= 0 then
						Result := indicators @ last_integer
					end
				end
			end
		end

	edit_parameter (p: FUNCTION_PARAMETER) is
			-- Allow the user to change the value of a function parameter.
		do
			print_list (<<"The current value for ", p.function.name, " is ",
						p.current_value, " - new value? ", eom>>)
			from
				read_line
			until
				p.valid_value (last_string)
			loop
				print_list (<<last_string, " is not valid, try again%N", eom>>)
				read_line
			end
			-- Since a member of the function library is being changed,
			-- it needs to be marked as dirty to ensure it gets saved.
			p.change_value (last_string)
			dirty := true
			print_list (<<"New value set to ", p.current_value, "%N">>)
		end

feature {NONE} -- Implementation - utilities

	remove_indicator (f: MARKET_FUNCTION) is
--Obsolete!!!
			-- Remove all occurrences of `f' from `function_library'.
		local
			l: LINKED_LIST [MARKET_FUNCTION]
			finished: BOOLEAN
		do
			l ?= function_library
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

	initialize is
		do
			-- Start out with non-intraday data:
			current_period_type := period_types @ (period_type_names @ Daily)
			create event_generator_builder.make
			create function_builder.make
			initialize_current_tradable
			if not market_list_handler.exhausted then
				available_period_types := market_list_handler.period_types (
					market_list_handler.current_symbol)
				if market_list_handler.error_occurred then
					log_errors (<<market_list_handler.last_error, "%N">>)
					raise ("Data retrieval error")
				end
			end
			working_function_library := deep_clone (function_library)
		ensure
			curr_period_not_void: current_period_type /= Void
		end

	initialize_current_tradable is
		require
			cpt_set: current_period_type /= Void
		do
			if market_list_handler.empty then
				current_tradable := Void
			else
				market_list_handler.start
				current_tradable :=
					market_list_handler.item (current_period_type)
				if market_list_handler.error_occurred then
					log_errors (<<market_list_handler.last_error, "%N">>)
					raise ("Data retrieval error")
				elseif current_tradable = Void then
					-- No daily data, so use intraday data.
					current_period_type := period_types @ (
						market_list_handler.period_types (
						market_list_handler.current_symbol) @ 1)
					current_tradable := market_list_handler.item (
						current_period_type)
				end
			end
		ensure
			mlh_at_first: not market_list_handler.empty implies
				market_list_handler.isfirst
		end

	product_info: STRING is
		local
			version: expanded PRODUCT_INFO
		do
			Result := concatenation (<<
				"%N", version.name, "%NVersion: ", version.number, "%N",
				version.copyright, "%NVersion date: ", version.informal_date,
				"%NLicence:%N%N", version.license_information>>)
		end

feature {NONE} -- Implementation - attributes

	end_client: BOOLEAN
			-- Has the user requested to terminate the command-line
			-- client session?

	exit_server: BOOLEAN
			-- Has the user requested to terminate the server?

	working_function_library: STORABLE_LIST [MARKET_FUNCTION]
			-- List of indicators used for editing until the user saves
			-- the current changes

	dirty: BOOLEAN
			-- Has a persistent entity been changed?

	saved_mklist_index: INTEGER

end -- class MAIN_CL_INTERFACE
