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

feature -- Access

	tradable: TRADABLE [BASIC_MARKET_TUPLE]

feature -- Status setting

	set_tradable (arg: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Set tradable to `arg'.
		require
			arg /= Void
		do
			tradable := arg
		ensure
			tradable_set: tradable = arg and tradable /= Void
		end

feature -- Basic operations

	execute is
		do
			tradable_menu
		end

feature {NONE}

	tradable_menu is
			-- Display the tradable menu and respond to the user's commands.
		local
			c: CHARACTER
		do
			from
			until
				end_program
			loop
				print_list (<<"Select action:  ", tradable.name,
							"View data (v) Edit parameters (e) Exit (x) %
							%Memory usage (m) ">>)
				inspect
					selected_character
				when 'v', 'V' then
					view_menu
				when 'e', 'E' then
					edit_menu
				when 'm', 'M' then
					display_memory_values
				when 'x', 'X' then
					end_program := true
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
				print ("Select action:%N%
						%     View market data (m) View an indicator (i)%N%
						%     View composite data (c) Exit (x) Previous (-) ")
				inspect
					selected_character
				when 'm', 'M' then
					print_tuples (tradable.data)
				when 'c', 'C' then
					print_composite_lists (tradable)
				when 'i', 'I' then
					print ("Select indicator to view%N")
					indicator := indicator_selection
					view_indicator_menu (indicator)
				when 'x', 'X' then
					end_program := true
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
				when '-' then
					done := true
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	indicator_selection: MARKET_FUNCTION is
		require
			not_trdble_empty: not tradable.indicators.empty
		local
			i: INTEGER
			indicators: LIST [MARKET_FUNCTION]
		do
			from
				indicators := tradable.indicators
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

feature {NONE}

	end_program: BOOLEAN

end -- class TEST_USER_INTERFACE
