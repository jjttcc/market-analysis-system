indexing
	description: "Top-level application interface - command-line driven"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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
		export
			{NONE} all
		undefine
			print
		end

	EXCEPTIONS
		export
			{NONE} all
		undefine
			print
		end

	UNIX_SIGNALS
		rename
			meaning as signal_meaning, ignore as ignore_signal,
			catch as catch_signal
		export
			{NONE} all
		undefine
			print
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

	current_tradable: TRADABLE [BASIC_MARKET_TUPLE] is
		do
			if market_list.empty then
				Result := Void
			else
				Result := market_list.item
			end
		end

	current_period_type: TIME_PERIOD_TYPE
			-- Current data period type to be processed

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
				end_client := false; exit_server := false
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
					selected_character
				when 's', 'S' then
					select_market
				when 'v', 'V' then
					view_menu
				when 'e', 'E' then
					main_edit_indicator_menu
				when 'm', 'M' then
					event_generator_builder.edit_event_generator_menu
				when 'r', 'R' then
					registrant_menu
				when 'a', 'A' then
					save_mklist_position
					-- Important - update the coordinator with the current
					-- active event generators:
					event_coordinator.set_event_generators (
						active_event_generators)
					event_coordinator.execute
					restore_mklist_position
				when 'd', 'D' then
					mkt_analysis_set_date_menu
				when 'x', 'X' then
					end_client := true
				when 'h', 'H' then
					print (help @ help.Main)
				when 'p', 'P' then
					print (product_info)
				when '%/5/' then -- ^E, for exit
					exit_server := true
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
			termination_cleanup
			if exit_server then
				exit (0)
			else
				print ("(Hit <Enter> to restart the command-line client.)%N")
			end
		rescue
			if not assertion_violation then
				if not is_signal then
					print_list (<<"Error encounted in main menu: ",
								meaning(exception), "%N">>)
				else
					print_list (<<"%NCaught signal: ", signal,
									", continuing ...%N">>)
				end
				if not end_client then
					retry
				end
			end
		end

feature {NONE}

	main_edit_indicator_menu is
			-- Menu for editing technical indicators (market functions)
		local
			finished: BOOLEAN
		do
			from
			until
				finished or end_client
			loop
				print_list (<<"Select action:",
					"%N     Create a new market-data indicator (c) %
					%Edit market-data indicators (m) %N%
					%     Edit market-analysis indicators (a) %
					%Exit (x) Previous (-) Help (h) ", eom>>)
				inspect
					selected_character
				when 'c', 'C' then
					function_library.extend (
						function_builder.function_selection_from_type (
							function_builder.market_function, "root function",
							true))
				when 'm', 'M' then
					if current_tradable /= Void then
						edit_indicator_menu (current_tradable.indicators)
					else
						print ("Market list is empty - cannot edit indicators %
								%unless at least one market is available.%N")
					end
				when 'a', 'A' then
					edit_event_generator_indicator_menu
				when 'x', 'X' then
					end_client := true
				when 'h', 'H' then
					print (help @ help.Edit_indicators)
				when '%/5/' then -- ^E, for exit
					exit_server := true; finished := true
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

	edit_event_generator_indicator_menu is
			-- Menu for editing market functions owned by event generators
		local
			analyzer: MARKET_EVENT_GENERATOR
			analyzers: LIST [MARKET_EVENT_GENERATOR]
			finished: BOOLEAN
			names: ARRAYED_LIST [STRING]
		do
			from
				analyzers := market_event_generation_library
				!!names.make (analyzers.count)
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
					finished := true
				else
					analyzer := analyzers @ last_integer
					edit_indicator_menu (analyzer.indicators)
				end
			end
		end

	edit_indicator_menu (indicators: LIST [MARKET_FUNCTION]) is
		require
			ind_not_void: indicators /= Void
		local
			indicator: MARKET_FUNCTION
			finished: BOOLEAN
			parameter: FUNCTION_PARAMETER
			parameters: LIST [FUNCTION_PARAMETER]
			i: INTEGER
		do
			from
				print ("Select indicator to edit%N")
				indicator := indicator_selection (indicators)
				parameters := indicator.parameters
			until
				finished
			loop
				print_list (<<"Select a parameter for ", indicator.name,
							" (0 to end):%N">>)
				from
					i := 1
					parameters.start
				until
					parameters.after
				loop
					print_list (<<i, ") ", parameters.item.function.name,
								" (value: ", parameters.item.current_value,
								")%N">>)
					parameters.forth
					i := i + 1
				end
				print (eom)
				read_integer
				if
					last_integer <= -1 or
						last_integer > parameters.count
				then
					print_list (<<"Selection must be between 0 and ",
								parameters.count, "%N">>)
				elseif last_integer = 0 then
					finished := true
				else
					parameter := parameters @ last_integer
					edit_parameter (parameter)
				end
			end
		end

	registrant_menu is
			-- Menu for adding, removing, editing, and viewing event
			-- registrants
		local
			finished: BOOLEAN
			registrar: EVENT_REGISTRATION
		do
			!!registrar.make (event_coordinator.dispatcher,
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
					selected_character
				when 'a', 'A' then
					registrar.add_registrants
				when 'r', 'R' then
					registrar.remove_registrants
				when 'v', 'V' then
					registrar.view_registrants
				when 'e', 'E' then
					registrar.edit_registrants
				when 'x', 'X' then
					end_client := true
				when 'h', 'H' then
					print (help @ help.Edit_event_registrants)
				when '%/5/' then -- ^E, for exit
					exit_server := true; finished := true
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


	view_menu is
			-- Menu for viewing market and market function data
		local
			finished: BOOLEAN
			indicator: MARKET_FUNCTION
		do
			if market_list.empty then
				print ("There are currently no markets to view.%N")
				finished := true
			end
			from
			until
				finished or end_client
			loop
				print_list (<<"Select action for ", current_tradable.name,
					":%N     View market data (m) View an indicator (i)%N%
					%     Change data period type [currently ",
					current_period_type.name,
					"] (c)%N     Exit (x) Previous (-) Help (h) ", eom>>)
				inspect
					selected_character
				when 'm', 'M' then
					print_tuples (current_tradable.tuple_list (
									current_period_type.name))
				when 'c', 'C' then
					select_period_type
				when 'i', 'I' then
					print ("Select indicator to view%N")
					indicator := indicator_selection
									(current_tradable.indicators)
					view_indicator_menu (indicator)
				when 'x', 'X' then
					end_client := true
				when 'h', 'H' then
					print (help @ help.View_data)
				when '%/5/' then -- ^E, for exit
					exit_server := true; finished := true
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

	mkt_analysis_set_date_menu is
			-- Obtain the date and time to begin market analysis from the
			-- user and pass it to the event generators.
		local
			date: DATE
			time: TIME
			date_time: DATE_TIME
			finished, set_date: BOOLEAN
			indicator: MARKET_FUNCTION
		do
			!!date.make_now
			!!time.make_now
			from
			until
				finished or end_client
			loop
				print_list (<<"Current date and time: ", date, ", ",
								time, "%N">>)
				print_list (<<"Select action:",
					"%N     Set date (d) Set time (t) %
					%Set date relative to current date (r)%N%
					%     Set market analysis date %
					%to currently selected date (s)%N",
					"     Previous (-) Exit (x) Help (h) ", eom>>)
				inspect
					selected_character
				when 'd', 'D' then
					date := date_choice
				when 't', 'T' then
					time := time_choice
				when 'r', 'R' then
					date := relative_date_choice
				when 'x', 'X' then
					end_client := true
				when 'h', 'H' then
					print (help @ help.Set_analysis_date)
				when '%/5/' then -- ^E, for exit
					exit_server := true; finished := true
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when 's', 'S' then
					finished := true
					set_date := true
				when '-' then
					finished := true
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
			if set_date then
				!!date_time.make_by_date_time (date, time)
				print_list (<<"Setting date and time for processing to ",
							date_time.out, "%N">>)
				event_coordinator.set_start_date_time (date_time)
			end
		end

	date_choice: DATE is
			-- Date obtained from user.
		do
			print_list (<<"Enter the date to use for analysis or %
				%hit <Enter> to use the%Ncurrent date (dd/mm/yyyy): ", eom>>)
			!!Result.make_now
			from
				read_line
			until
				last_string.empty or Result.date_valid (last_string)
			loop
				print_list (<<"Date format invalid, try again: ", eom>>)
				read_line
			end
			if not last_string.empty then
				!!Result.make_from_string (last_string)
			end
			print_list (<<"Using date of ", Result, ".%N">>)
		end

	relative_date_choice: DATE is
			-- Date obtained from user.
		local
			period: CHARACTER
			period_name: STRING
		do
			!!Result.make_now
			from
			until
				period = 'd' or period = 'm' or period = 'y'
			loop
				print_list (<<"Select period length:%N%
					%     day (d) month (m) year (y) ", eom>>)
				inspect
					selected_character
				when 'd', 'D' then
					period := 'd'
					period_name := "day"
				when 'm', 'M' then
					period := 'm'
					period_name := "month"
				when 'y', 'Y' then
					period := 'y'
					period_name := "year"
				else
					print ("Invalid selection%N")
				end
			end
			print_list (<<"Enter the number of ", period_name,
						"s to set date back relative to today: ", eom>>)
			from
				read_integer
			until
				last_integer >= 0
			loop
				print_list (<<"Invalid number, try again: ", eom>>)
				read_integer
			end
			inspect
				period
			when 'd' then
				Result.day_add (-last_integer)
			when 'm' then
				Result.month_add (-last_integer)
			when 'y' then
				Result.year_add (-last_integer)
			end
			print_list (<<"Using date of ", Result, ".%N">>)
		end

	time_choice: TIME is
			-- Time obtained from user.
		do
			!!Result.make (0, 0, 0)
			print_list (<<"Enter the hour to use for analysis: ", eom>>)
			from
				read_integer
			until
				last_integer >= 0 and last_integer < Result.Hours_in_day
			loop
				print_list (<<"Invalid hour, try again: ", eom>>)
				read_integer
			end
			Result.set_hour (last_integer)
			print_list (<<"Enter the minute to use for analysis: ", eom>>)
			from
				read_integer
			until
				last_integer >= 0 and last_integer < Result.Minutes_in_hour
			loop
				print_list (<<"Invalid minute, try again: ", eom>>)
				read_integer
			end
			Result.set_minute (last_integer)
			print_list (<<"Using time of ", Result, ".%N">>)
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
					selected_character
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
					end_client := true
				when 'h', 'H' then
					print (help @ help.View_indicator)
				when '%/5/' then -- ^E, for exit
					exit_server := true; finished := true
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

	select_market is
			-- Allow the user to select the current market so that
			-- market_list.item is the selected market.
		local
			symbol: STRING
			symbols: LIST [STRING]
		do
			if not market_list.empty then
				from
					symbols := market_list.symbols
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
				market_list.search_by_symbol (symbol)
				-- current_tradable will be set to the current item of
				-- market_list (which, because of the above call, corresponds
				-- to file `symbol').
				-- Update the current_tradable's target period type, if needed.
				if
					current_tradable.target_period_type /= current_period_type
				then
					current_tradable.set_target_period_type (
						current_period_type)
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
		do
			if not market_list.empty then
				from
					i := 1
					types := current_tradable.tuple_list_names
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
				current_period_type := period_types @ (types @ last_integer)
				print_list (<<"Data period type set to ",
							current_period_type.name, "%N">>)
						current_tradable.set_target_period_type (
							current_period_type)
			else
				print ("There are no markets to select a period type for.%N")
			end
		end

	indicator_selection (indicators: LIST [MARKET_FUNCTION]):
				MARKET_FUNCTION is
			-- User-selected indicator
		require
			not_void_or_empty: indicators /= Void and not indicators.empty
		local
			names: ARRAYED_LIST [STRING]
		do
			from
				!!names.make (indicators.count)
				from
					indicators.start
				until
					indicators.exhausted
				loop
					names.extend (indicators.item.name)
					indicators.forth
				end
			until
				Result /= Void
			loop
				print_names_in_1_column (names, 1)
				print (eom)
				read_integer
				print_list (<<"You selected number ", last_integer, "%N">>)
				if
					last_integer <= 0 or
						last_integer > indicators.count
				then
					print_list (<<"Selection must be between 1 and ",
								indicators.count, "%N">>)
				else
					Result := indicators @ last_integer
				end
			end
		end

	edit_parameter (p: FUNCTION_PARAMETER) is
			-- Allow the user to change the value of a function parameter.
		do
			print_list (<<"The current value for ", p.function.name, " is ",
						p.current_value, " - new value? ", eom>>)
			from
				read_integer
			until
				p.valid_value (last_integer)
			loop
				print_list (<<last_integer, " is not valid, try again%N", eom>>)
				read_integer
			end
			p.change_value (last_integer)
			print_list (<<"New value set to ", p.current_value, "%N">>)
		end

feature {NONE}

	save_mklist_position is
			-- Save the current position of `market_list' for later restoring.
		do
			saved_mklist_index := market_list.index
		end

	restore_mklist_position is
			-- Restore `market_list' cursor to last saved position
		require
			saved_mklist_index > 0
		do
			from
				if saved_mklist_index < market_list.index then
					market_list.start
				end
			until
				market_list.index = saved_mklist_index
			loop
				market_list.forth
			end
		end

	initialize is
		do
			current_period_type := period_types @ (period_type_names @ Daily)
			!!event_generator_builder.make
			!!function_builder.make
		ensure
			curr_period_not_void: current_period_type /= Void
		end

	exit (status: INTEGER) is
			-- Exit the server with the specified status
		do
			if status /= 0 then
				io.print ("Aborting the server.%N")
			else
				io.print ("Terminating the server.%N")
			end
			die (status)
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

feature {NONE}

	end_client: BOOLEAN
			-- Has the user requested to terminate the command-line
			-- client session?

	exit_server: BOOLEAN
			-- Has the user requested to terminate the server?

	saved_mklist_index: INTEGER --!!!Is this ever used????

end -- class MAIN_CL_INTERFACE
