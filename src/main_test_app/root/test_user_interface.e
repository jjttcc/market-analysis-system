indexing
	description: "User interface for testing"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TEST_USER_INTERFACE inherit

	STD_FILES

	PRINTING
		export {NONE}
			all
				{ANY}
			set_output_field_separator, set_date_field_separator
		end

	MEM_INFO
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export {NONE}
			all
		end

	EXECUTION_ENVIRONMENT
		export {NONE}
			all
		end

feature -- Access

	event_coordinator: MARKET_EVENT_COORDINATOR

	factory_builder: FACTORY_BUILDER
	
	market_list: TRADABLE_LIST

	input_file_names: LIST [STRING]

	current_tradable: TRADABLE [BASIC_MARKET_TUPLE] is
		do
			Result := market_list.item
		end

	current_period_type: TIME_PERIOD_TYPE
			-- Current data period type to be processed

feature -- Status setting

	set_factory_builder (arg: FACTORY_BUILDER) is
			-- Set factory_builder to `arg'.
		require
			arg_not_void: arg /= Void
		do
			factory_builder := arg
		ensure
			factory_builder_set: factory_builder = arg and
									factory_builder /= Void
		end

	set_event_coordinator (arg: MARKET_EVENT_COORDINATOR) is
			-- Set event_coordinator to `arg'.
		require
			arg /= Void
		do
			event_coordinator := arg
		ensure
			event_coordinator_set: event_coordinator = arg and
									event_coordinator /= Void
		end

feature -- Basic operations

	execute is
		do
			initialize
			tradable_menu
		end

feature {NONE}

	tradable_menu is
			-- Display the tradable menu and respond to the user's commands.
		local
			c: CHARACTER
			cursor: CURSOR
		do
			from
			until
				end_program
			loop
				print_list (<<"Select action:%N", "     Select market (s) ",
							"View data (v) Edit parameters (e)",
							"%N     Run market analysis (r) ",
							"Set date for market analysis (d)%N",
							"     Memory usage (m) Exit (x) ">>)
				inspect
					selected_character
				when 's', 'S' then
					select_market
				when 'v', 'V' then
					view_menu
				when 'e', 'E' then
					edit_menu
				when 'm', 'M' then
					display_memory_values
				when 'r', 'R' then
					save_mklist_position
					event_coordinator.execute
					restore_mklist_position
				when 'd', 'D' then
					mkt_analysis_set_date_menu
				when 'x', 'X' then
					end_program := true
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
			check
				finished: end_program
			end
			-- Ensure that all objects registered for cleanup on termination
			-- are notified of termination.
			termination_cleanup
		end

	edit_menu is
		local
			indicator: MARKET_FUNCTION
			finished: BOOLEAN
			parameter: FUNCTION_PARAMETER
			parameters: LIST [FUNCTION_PARAMETER]
			i: INTEGER
		do
			from
				print ("Select indicator to edit%N")
				indicator := indicator_selection
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
								" - value: ", parameters.item.current_value,
								"%N">>)
					parameters.forth
					i := i + 1
				end
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

	view_menu is
		local
			done: BOOLEAN
			indicator: MARKET_FUNCTION
		do
			from
			until
				done or end_program
			loop
				print_list (<<"Select action for ", current_tradable.name,
					":%N     View market data (m) View an indicator (i)%N%
					%     Change data period type [currently ",
					current_period_type.name, "] (c) Exit (x) Previous (-) ">>)
				inspect
					selected_character
				when 'm', 'M' then
					print_tuples (current_tradable.tuple_list (
									current_period_type.name))
				when 'c', 'C' then
					select_period_type
					--!!!print_composite_lists (current_tradable)
				when 'i', 'I' then
					print ("Select indicator to view%N")
					indicator := indicator_selection
					view_indicator_menu (indicator)
				when 'x', 'X' then
					end_program := true
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					done := true
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
			done: BOOLEAN
			indicator: MARKET_FUNCTION
		do
			!!date.make_now
			!!time.make_now
			from
			until
				done or end_program
			loop
				print_list (<<"Current date and time: ", date, ", ",
								time, "%N">>)
				print_list (<<"Select action:",
					"%N     Set date (d) Set time (t) %
					%Set date relative to current date (r)%N%
					%     Set market analysis date %
					%to currently selected date (s) Exit (x) ">>)
				inspect
					selected_character
				when 'd', 'D' then
					date := date_choice
				when 't', 'T' then
					time := time_choice
				when 'r', 'R' then
					date := relative_date_choice
				when 'x', 'X' then
					end_program := true
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when 's', 'S' then
					done := true
				else
					print ("Invalid selection%N")
				end
			end
			!!date_time.make_by_date_time (date, time)
			print_list (<<"Setting date and time for processing to ",
						date_time.out, "%N">>)
			event_coordinator.set_start_date_time (date_time)
		end

	date_choice: DATE is
			-- Date obtained from user.
		do
			print ("Enter the date to use for analysis or %
				%hit <Enter> to use the%Ncurrent date (dd/mm/yyyy): ")
			!!Result.make_now
			from
				read_line
			until
				last_string.empty or Result.date_valid (last_string)
			loop
				print ("Date format invalid, try again: ")
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
				print ("Select period length:%N%
					%     day (d) month (m) year (y) ")
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
						"s to set date back relative to today: ">>)
			from
				read_integer
			until
				last_integer >= 0
			loop
				print ("Invalid number, try again: ")
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
			print ("Enter the hour to use for analysis: ")
			from
				read_integer
			until
				last_integer >= 0 and last_integer < Result.Hours_in_day
			loop
				print ("Invalid hour, try again: ")
				read_integer
			end
			Result.set_hour (last_integer)
			print ("Enter the minute to use for analysis: ")
			from
				read_integer
			until
				last_integer >= 0 and last_integer < Result.Minutes_in_hour
			loop
				print ("Invalid minute, try again: ")
				read_integer
			end
			Result.set_minute (last_integer)
			print_list (<<"Using time of ", Result, ".%N">>)
		end

	display_memory_values is
		do
			update (Total_memory)
			print_list (<<total, " bytes free%N", used + overhead,
						" total bytes used%N", overhead,
						" overhead bytes used%N", used, " bytes used%N">>)
		end

	view_indicator_menu (indicator: MARKET_FUNCTION) is
		local
			done: BOOLEAN
		do
			from
			until
				done or end_program
			loop
				print ("Select action:%N%
						%     Print indicator (p) View description (d) %N%
						%     View long description (l) Exit (x) previous (-) ")
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
					end_program := true
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					done := true
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	select_market is
		local
			i: INTEGER
			fname: STRING
		do
			from
			until
				fname /= Void
			loop
				from
					i := 1
					input_file_names.start
				until
					input_file_names.after
				loop
					print_list (<<i, ") ", input_file_names.item, "%N">>)
					input_file_names.forth
					i := i + 1
				end
				read_integer
				if
					last_integer <= 0 or
						last_integer > input_file_names.count
				then
					print_list (<<"Selection must be between 1 and ",
								input_file_names.count, "%N">>)
				else
					fname := input_file_names @ last_integer
				end
			end
			market_list.search_by_file_name (fname)
			-- current_tradable will be set to the current item of market_list
			-- (which, because of the above call, corresponds to file fname).
			-- Update the current_tradable's target period type, if needed.
			if current_tradable.target_period_type /= current_period_type then
				current_tradable.set_target_period_type (current_period_type)
			end
		end

	select_period_type is
			-- Obtain selection for current_period_type from user and set
			-- the current tradable's target_period_type to it.
		local
			i: INTEGER
			types: ARRAY [STRING]
		do
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
				read_integer
			until
				last_integer > 0 and last_integer <= types.count
			loop
				print_list (<<"Selection must be between 1 and ",
							types.count, " - try again: %N">>)
				read_integer
			end
			current_period_type := period_types @ (types @ last_integer)
			print_list (<<"Data period type set to ",
						current_period_type.name, "%N">>)
					current_tradable.set_target_period_type (
						current_period_type)
		end

	indicator_selection: MARKET_FUNCTION is
		require
			not_trdble_empty: not current_tradable.indicators.empty
		local
			i: INTEGER
			indicators: LIST [MARKET_FUNCTION]
		do
			from
				indicators := current_tradable.indicators
			until
				Result /= Void
			loop
				from
					i := 1
					indicators.start
				until
					indicators.after
				loop
					print_list (<<i, ") ", indicators.item.name, "%N">>)
					indicators.forth
					i := i + 1
				end
				read_integer
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
		do
			print_list (<<"The current value for ", p.function.name, " is ",
						p.current_value, " - new value? ">>)
			from
				read_integer
			until
				p.valid_value (last_integer)
			loop
				print_list (<<last_integer, " is not valid, try again%N">>)
				read_integer
			end
			p.change_value (last_integer)
			print_list (<<"New value set to ", p.current_value, "%N">>)
		end

feature {NONE}

	selected_character: CHARACTER is
			-- Character selected by user
		do
			from
				Result := '%U'
			until
				Result /= '%U'
			loop
				read_line
				if laststring.count > 0 then
					Result := laststring @ 1
				end
			end
		end

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
			event_coordinator := factory_builder.event_coordinator
			current_period_type := period_types @ "daily"
			market_list := factory_builder.market_list
			input_file_names := factory_builder.input_file_names
			event_coordinator := factory_builder.event_coordinator
		ensure
			curr_period_not_void: current_period_type /= Void
			event_coordinator_not_void: event_coordinator /= Void
			market_list_not_void: market_list /= Void
			input_file_names_not_void: input_file_names /= Void
			event_coordinator_not_void: event_coordinator /= Void
		end

feature {NONE}

	end_program: BOOLEAN

	saved_mklist_index: INTEGER

end -- class TEST_USER_INTERFACE
