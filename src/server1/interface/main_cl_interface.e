indexing
	description: "Top-level application interface - command-line driven"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAIN_CL_INTERFACE inherit

	EXECUTION_ENVIRONMENT
		export {NONE}
			all
		undefine
			print
		end

	MAS_COMMAND_LINE_UTILITIES
		redefine
			set_console, set_no_console
		end

	PRINTING
		rename
			output_medium as output_device
		export
			{NONE} all
		undefine
			print
		end

	EXCEPTION_SERVICES
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

	EVENT_HISTORY_MANAGEMENT
		export
			{NONE} all
		undefine
			print
		end

	MARKET_FUNCTION_EDITOR
		export
			{NONE} all
		undefine
			print
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
			create event_registrar.make (input_device, output_device)
		ensure
			iodev_set: input_device = input_dev and output_device = output_dev
		end

feature -- Access

	current_tradable: TRADABLE [BASIC_MARKET_TUPLE]

	current_period_type: TIME_PERIOD_TYPE
			-- Current data period type to be processed

	available_period_types: ARRAYED_LIST [STRING] is
			-- List of all period types available for selection for
			-- current_tradable
		do
			if
				current_tradable /= last_tradable_for_period_types and
				current_tradable /= Void
			then
				last_period_types := tradable_list_handler.period_types (
					current_tradable.symbol)
				last_tradable_for_period_types := current_tradable
			end
			Result := last_period_types
		end

	event_generator_builder: CL_BASED_MEG_EDITING_INTERFACE

	function_builder: CL_BASED_FUNCTION_EDITING_INTERFACE

	event_registrar: EVENT_REGISTRATION

feature -- Status setting

	set_input_device (arg: IO_MEDIUM) is
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
			event_generator_builder.set_input_device (arg)
			function_builder.set_input_device (arg)
			if event_registrar = Void then
				create event_registrar.make (io.input, io.output)
			end
			event_registrar.set_input_device (arg)
		ensure
			input_device_set: input_device = arg and input_device /= Void
			gen_builder_in_set: event_generator_builder.input_device  = arg
			function_builder_in_set: function_builder.input_device = arg
			registrar_in_set: event_registrar.input_device = arg
		end

	set_output_device (arg: IO_MEDIUM) is
			-- Set output_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_device := arg
			event_generator_builder.set_output_device (arg)
			function_builder.set_output_device (arg)
			if event_registrar = Void then
				create event_registrar.make (io.input, io.output)
			end
			event_registrar.set_output_device (arg)
		ensure
			output_device_set: output_device = arg and output_device /= Void
			gen_builder_out_set: event_generator_builder.output_device  = arg
			function_builder_out_set: function_builder.output_device = arg
			registrar_out_set: event_registrar.output_device = arg
		end

	set_console is
		do
			Precursor
			event_generator_builder.set_console
			function_builder.set_console
			event_registrar.set_console
		end

	set_no_console is
		do
			Precursor
			event_generator_builder.set_no_console
			function_builder.set_no_console
			event_registrar.set_no_console
		end

feature -- Basic operations

	main_menu is
			-- Display the main menu and respond to the user's commands.
		local
			exception_processor: expanded EXCEPTION_PROCESSOR
			retried: BOOLEAN
		do
print ("main_menu starting.%N")
not_verbose_reporting := False
check verbose_reporting end
			if
				retried implies not end_client and then
				not exception_processor.abort_command_line_processing
			then
				process_main_menu
			end
print ("main_menu returning.%N")
		rescue
			handle_exception ("main menu")
			if
				not exit_server and not assertion_violation
			then
				retried := True
print ("main_menu retrying.%N")
				retry
			else
print ("main_menu terminating.%N")
				terminate (Error_exit_status)
			end
		end

	process_main_menu is
		do
print ("process_main_menu starting.%N")
			check
				io_devices_not_void: input_device /= Void and
										output_device /= Void
			end
			if current_tradable = Void then
				initialize_current_tradable
			end
			from
				end_client := False; exit_server := False
			until
				end_client or exit_server
			loop
				print_list (<<"Select action:%N", "     Select tradable (s) ",
							"View data (v) Edit indicators (e)",
							"%N     Edit market analyzers (m) ",
							"Run market analysis (a)%N",
							"     Set date for market analysis (d) ",
							"Edit event registrants (r)%N",
							"     End client session (x) Help (h) ",
							"Product information (p)%N",
							"     Show settings (w) ",
							eom>>)
				inspect
					character_selection (Void)
				when 's', 'S' then
					select_tradable
				when 'v', 'V' then
					view_menu
				when 'e', 'E' then
					function_builder.edit_indicator_menu
					if
						function_builder.changed and current_tradable /= Void
					then
						tradable_list_handler.clear_caches
						current_tradable := 
						tradable_list_handler.tradable (current_tradable.symbol,
							current_period_type)
					end
				when 'm', 'M' then
					event_generator_builder.edit_event_generator_menu
				when 'r', 'R' then
					event_registrar.registrant_menu
				when 'a', 'A' then
					run_market_analysis
				when 'd', 'D' then
					mkt_analysis_set_date_menu
				when 'x', 'X' then
					end_client := True
				when 'h', 'H' then
					print (help @ help.Main)
				when 'p', 'P' then
					print (product_info)
				when 'w', 'W' then
					print (settings)
				when '%/5/' then -- ^E, for exit
					exit_server := True
				when '!' then
					execute_shell_command
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
			check
				finished: end_client or exit_server
			end
			-- Notify client that it can terminate:
			print (Eot)
			if exit_server then
				exit (0)
			else
				print ("(Hit <Enter> to restart the command-line client.)%N")
			end
print ("process_main_menu returning.%N")
		end

feature {NONE} -- Implementation

	view_menu is
			-- Menu for viewing market and market function data
		local
			finished: BOOLEAN
			indicator: MARKET_FUNCTION
		do
			if tradable_list_handler.is_empty then
				print ("There are currently no tradables to view.%N")
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
					if
						current_tradable.indicators = Void or
						current_tradable.indicators.is_empty
					then
						print ("There are currently no indicators to view.%N")
					else
						print ("Select indicator to view (0 to end):%N")
						indicator := indicator_selection
										(current_tradable.indicators)
						if indicator /= Void then
							view_indicator_menu (indicator)
						end
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
					execute_shell_command
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
		do
			event_coordinator.set_start_date_time (date_time_selection (
				"%NPlease selecte a date and time for market analysis."))
		end

	run_market_analysis is
			-- Run market analysis using event coordinator.
		do
			if event_coordinator.start_date_time = Void then
				log_error ("%NError: Start date must be set before %
					%running analysis.%N")
			elseif tradable_list_handler.is_empty then
				print ("%NNo tradables to analyze - tradable list is empty.%N")
			else
				-- Ensure that the market event generators and event
				-- registrants currently in persistent store are used
				-- for the market analysis (in case they were updated by
				-- a separate process).
				force_meg_library_retrieval
				force_event_registrant_retrieval
				-- Important - update the coordinator with the current
				-- active event generators:
				event_coordinator.set_event_generators (
					active_event_generators)
				factory_builder.make_dispatcher
				event_coordinator.set_dispatcher (factory_builder.dispatcher)
				load_market_event_histories
				if error_occurred then log_errors (<<last_error, "%N">>) end
				event_coordinator.execute
				save_market_event_histories
			end
		end

	view_indicator_menu (indicator: MARKET_FUNCTION) is
			-- Menu for viewing market function data
		local
			finished: BOOLEAN
			gs: expanded GLOBAL_SERVER_FACILITIES
		do
			from
			until
				finished or end_client
			loop
				print_list (<<"Select action:%N%
						%     Print indicator (p) View description (d) %N%
						%     View long description (l) Exit (x) Previous (-) %
						%Help (h) ", eom>>)
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
					execute_shell_command
				when '-' then
					finished := True
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	select_tradable is
			-- Allow the user to select the current tradable so that
			-- tradable_list_handler.item (current_period_type) is the
			-- selected tradable.
		local
			symbol: STRING
			symbols: LIST [STRING]
			old_tradable: TRADABLE [BASIC_MARKET_TUPLE]
			err: STRING
		do
			old_tradable := current_tradable
			if not tradable_list_handler.is_empty then
				from
					symbols := tradable_list_handler.symbols
				until
					symbol /= Void
				loop
					print_names_in_n_columns (symbols, 4)
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
					symbol_in_list: tradable_list_handler.symbols.has (symbol)
				end
				current_tradable := tradable_list_handler.tradable (symbol,
					current_period_type)
				if
					tradable_list_handler.error_occurred or
					current_tradable = Void
				then
					if tradable_list_handler.error_occurred then
						err := concatenation (
							<<tradable_list_handler.last_error, ".%N">>)
					else
						check
							not_valid:
							not tradable_list_handler.valid_period_type (symbol,
							current_period_type)
						end
						err := concatenation (
							<<"Invalid period type for ", symbol,
							": ", current_period_type.name, ".%N">>)
					end
					log_error (err)
					current_tradable := old_tradable
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
				print ("There are no tradables available to select from.%N")
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
			if not tradable_list_handler.is_empty then
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
					if
						tradable_list_handler.valid_period_type (t.symbol,
							per_type_choice)
					then
						-- Set `t' to the appropriate tradable according to
						-- `per_type_choice', intraday or non-intraday.
						t := tradable_list_handler.tradable (t.symbol,
							per_type_choice)
					end
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
				print ("There are no tradables to select a period type for.%N")
			end
		end

	indicator_selection (indicators: LIST [MARKET_FUNCTION]):
				MARKET_FUNCTION is
			-- User-selected indicator by number - Void if user chooses 0
		require
			not_void_or_empty: indicators /= Void and not indicators.is_empty
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

feature {NONE} -- Implementation - utilities

	initialize is
		do
			no_cleanup := False
			-- Start out with non-intraday data:
			current_period_type := period_types @ (period_type_names @ Daily)
			create event_generator_builder.make
			create function_builder.make (tradable_list_handler)
		ensure
			curr_period_not_void: current_period_type /= Void
		end

	initialize_current_tradable is
		require
			cpt_set: current_period_type /= Void
		do
print ("initialize_current_tradable starting.%N")
			if tradable_list_handler.is_empty then
print ("initialize_current_tradable - tradable list handler is empty.%N")
				current_tradable := Void
			else
				tradable_list_handler.start
print ("initialize_current_tradable - tradable list handler has " +
tradable_list_handler.symbols.count.out + " elements.%N")
print ("executing 'current_tradable := tradable_list_handler.item %
	%(current_period_type)%N")
				current_tradable :=
					tradable_list_handler.item (current_period_type)
if current_tradable /= Void then
print ("non-intraday data for " + current_tradable.symbol +
"retrieved successfully.%N")
end
				if tradable_list_handler.error_occurred then
print ("Call to tradable_list_handler.item failed, exiting ...%N")
					log_errors (<<tradable_list_handler.last_error, "%N">>)
					terminate (Error_exit_status)
				elseif current_tradable = Void then
print ("Call to tradable_list_handler.item returned Void.%N")
					-- No daily data, so use intraday data.
					if not tradable_list_handler.error_occurred then
print ("Calling tradable_list_handler.item for intraday data.%N")
						current_period_type := period_types @ (
							tradable_list_handler.period_types (
								tradable_list_handler.current_symbol) @ 1)
						current_tradable := tradable_list_handler.item (
							current_period_type)
if current_tradable /= Void then
print ("intraday data for " + current_tradable.symbol +
"retrieved successfully.%N")
else
print ("Call to tradable_list_handler.item for intraday data returned Void.%N")
end
					end
				end
			end
print ("initialize_current_tradable returning.%N")
		ensure
			mlh_at_first: not tradable_list_handler.is_empty implies
				tradable_list_handler.isfirst
		rescue
			-- Exceptions caught during initialization are considered fatal.
print ("initialize_current_tradable caught fatal exception.%N")
			last_exception_status.set_fatal (True)
			handle_exception ("Initialization error")
		end

	product_info: STRING is
		local
			version: expanded MAS_PRODUCT_INFO
		do
			Result := "%N" + version.name + "%NVersion: " + version.number +
				"%N" + version.copyright + "%NVersion date: " +
				version.informal_date + "%N" + version.assertion_report +
				"%NLicence:%N%N" + version.license_information
		end

	settings: STRING is
		local
			ms: expanded MAS_SETTINGS
		do
			Result := "%N" + ms.data_source_report + "%N%N" +
			ms.app_directory_report + "%N%N" +
			ms.working_directory_report + "%N%N" +
			ms.email_report + "%N"
		end

	make_lock (name: STRING): FILE_LOCK is
		local
			gs: expanded GLOBAL_SERVER_FACILITIES
		do
			Result := gs.file_lock (name)
		end

	terminate (status: INTEGER) is
			-- Notify client of termination and then exit.
		do
			print (Eot)
			exit (status)
		end

feature {NONE} -- Implementation - attributes

	end_client: BOOLEAN
			-- Has the user requested to terminate the command-line
			-- client session?

	exit_server: BOOLEAN
			-- Has the user requested to terminate the server?

	saved_mklist_index: INTEGER

	last_period_types: ARRAYED_LIST [STRING]

	last_tradable_for_period_types: TRADABLE [BASIC_MARKET_TUPLE]

end -- class MAIN_CL_INTERFACE
