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
				print ("Select action:  ")
				print (tradable.name)
				print ("View data (v) Edit parameters (e) Exit (x) %
						%Admin (a) ")
				inspect
					selected_character
				when 'v', 'V' then
					view_menu
				when 'e', 'E' then
					edit_menu
				when 'a', 'A' then
					admin_menu
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
				print ("Select a parameter for ");
				print (indicator.name); print (" (0 to end):%N")
				from
					i := 1
					parameters.start
				until
					parameters.after
				loop
					print (i.out); print (") ")
					print (parameters.item.function.name)
					print (" - value: ")
					print (parameters.item.current_value)
					print ("%N")
					parameters.forth
					i := i + 1
				end
				read_integer
				if
					last_integer <= -1 or
						last_integer > parameters.count
				then
					print ("Selection must be between 0 and ")
					print (parameters.count); print ("%N")
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
				print ("Select action:%N")
				print ("     View market data (m) View an indicator (i)%N%
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

	admin_menu is
		local
			done: BOOLEAN
		do
			from
			until
				done or end_program
			loop
				update (Total_memory)
				print ("Select action:%N")
				print ("     Available memory (m) Total memory used %
						% [u + o] (t)%N%
						%     Overhead (o) Memory used (u)%N%
						%     Exit (x) Previous (-) ")
				inspect
					selected_character
				when 'm', 'M' then
					print (total); print (" bytes free%N")
				when 't', 'T' then
					print (used + overhead); print (" total bytes used%N")
				when 'o', 'O' then
					print (overhead); print (" overhead bytes used%N")
				when 'u', 'U' then
					print (used); print (" bytes used%N")
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

	view_indicator_menu (indicator: MARKET_FUNCTION) is
		local
			done: BOOLEAN
		do
			from
			until
				done or end_program
			loop
				print ("Select action:%N")
				print ("     Print indicator (p) View description (d) %N%
						%     View long description (l) Exit (x) previous (-) ")
				inspect
					selected_character
				when 'p', 'P' then
					if not indicator.processed then
						print ("Processing ")
						print (indicator.name); print (" ...%N")
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
					print (i.out); print (") ")
					print (indicators.item.name)
					print ("%N")
					indicators.forth
					i := i + 1
				end
				read_integer
				if
					last_integer <= 0 or
						last_integer > indicators.count
				then
					print ("Selection must be between 1 and ")
					print (indicators.count); print ("%N")
				else
					Result := indicators @ last_integer
				end
			end
		end

	edit_parameter (p: FUNCTION_PARAMETER) is
		do
			print ("The current value for ")
			print (p.function.name); print (" is ")
			print (p.current_value); print (" - new value? ")
			from
				read_integer
			until
				p.valid_value (last_integer)
			loop
				print (last_integer.out)
				print (" is not valid, try again%N")
				read_integer
			end
			p.change_value (last_integer)
			print ("New value set to ")
			print (p.current_value)
			print ("%N")
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
