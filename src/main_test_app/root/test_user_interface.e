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

	event_coordinator: EVENT_COORDINATOR

	factory_builder: FACTORY_BUILDER
	
	market_list: TRADABLE_LIST

	input_file_names: LIST [STRING]

	current_tradable: TRADABLE [BASIC_MARKET_TUPLE] is
		do
			Result := market_list.item
		end

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

	set_event_coordinator (arg: EVENT_COORDINATOR) is
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
							"Memory usage (m) Exit (x) ">>)
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
					%     View composite data (c) Exit (x) Previous (-) ">>)
				inspect
					selected_character
				when 'm', 'M' then
					print_tuples (current_tradable.data)
				when 'c', 'C' then
					print_composite_lists (current_tradable)
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
			market_list := factory_builder.market_list
			input_file_names := factory_builder.input_file_names
			event_coordinator := factory_builder.event_coordinator
		end

feature {NONE}

	end_program: BOOLEAN

	saved_mklist_index: INTEGER

end -- class TEST_USER_INTERFACE
