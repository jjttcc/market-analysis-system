indexing
	description:
		"Builder/editor of MARKET_EVENT_GENERATORs using a command-line %
		%interface"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class CL_BASED_MEG_EDITING_INTERFACE inherit

	COMMAND_LINE_UTILITIES [MARKET_EVENT_GENERATOR]
		rename
			print_message as show_message
		export
			{NONE} all
			{ANY} input_device, output_device
		end

	MEG_EDITING_INTERFACE
		undefine
			print
		redefine
			operator_maker, function_editor, help
		end

	TERMINABLE
		undefine
			print
		end

	GLOBAL_SERVER
		export
			{NONE} all
		undefine
			print
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		undefine
			print
		end

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		undefine
			print
		end

creation

	make

feature -- Initialization

	make is
		do
			create {CL_BASED_COMMAND_EDITING_INTERFACE}
				operator_maker.make (True)
			create help.make
			-- Satisfy invariant (editor is currently not used.)
			create editor
			create function_editor.make (Void)
			operator_maker.set_market_tuple_selector (function_editor)
			register_for_termination (Current)
		ensure
			editor_exists: editor /= Void
			operator_maker_exists: operator_maker /= Void
		end

feature -- Access

	operator_maker: CL_BASED_COMMAND_EDITING_INTERFACE

	function_editor: CL_BASED_FUNCTION_EDITING_INTERFACE

feature -- Status setting

	set_input_device (arg: IO_MEDIUM) is
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
			operator_maker.set_input_device (arg)
			function_editor.set_input_device (input_device)
		ensure
			input_device_set: input_device = arg and input_device /= Void
		end

	set_output_device (arg: IO_MEDIUM) is
			-- Set output_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_device := arg
			operator_maker.set_output_device (arg)
			function_editor.set_output_device (output_device)
		ensure
			output_device_set: output_device = arg and output_device /= Void
		end

feature {NONE} -- Implementation

	main_menu_selection: INTEGER is
		local
			msg: STRING
		do
			check
				io_devices_not_void: input_device /= Void and
										output_device /= Void
			end
			if not dirty or not ok_to_save then
				msg := concatenation (<<"Select action:",
					"%N     Create a new market analyzer (c) %
					%Remove a market analyzer (r) %
					%%N     View a market analyzer (v) %
					%Edit market-analysis indicators (e) %N%
					%     Previous (-) Help (h) ", eom>>)
			else
				msg := concatenation (<<"Select action:",
					"%N     Create a new market analyzer (c) %
					%Remove a market analyzer (r) %
					%%N     View a market analyzer (v) %
					%Edit market-analysis indicators (e) %N%
					%     Save changes (s) %
					%Previous - abort changes (-) Help (h) ", eom>>)
			end
			from
				Result := Null_value
			until
				Result /= Null_value
			loop
				print (msg)
				inspect
					character_selection (Void)
				when 'c', 'C' then
					Result := Create_new_value
				when 'r', 'R' then
					Result := Remove_value
				when 'v', 'V' then
					Result := View_value
				when 'e', 'E' then
					Result := Edit_value
				when 's', 'S' then
					if not dirty or not ok_to_save then
						print ("Invalid selection%N")
					else
						Result := Save_value
					end
				when 'h', 'H' then
					Result := Show_help_value
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					Result := Exit_value
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	eg_selection (msg: STRING): INTEGER is
		local
			finished: BOOLEAN
		do
			Result := backoutable_selection (meg_names (working_meg_library),
				concatenation (<<"Select a market analyzer", msg>>),
				Exit_value)
		end

	event_generator_type_selection: INTEGER is
		local
			c: CHARACTER
		do
			from
			until
				c /= '%U'
			loop
				print_list (<<"Select analyzer type: ",
							"Simple (s) Compound (c) ", eom>>)
				c := character_selection (Void)
				if not (c = 's' or c = 'S' or c = 'c' or c = 'C') then
					c := '%U'
					print_list (<<"Invalid selection: ", c, "%N">>)
				end
			end
			inspect
				c
			when 's', 'S' then
				Result := Simple_eg_type_value
			when 'c', 'C' then
				Result := Compound_eg_type_value
			end
		end

	event_generator_selection (msg: STRING): MARKET_EVENT_GENERATOR is
			-- User's event generator selection
		local
			finished: BOOLEAN
		do
			if meg_names (working_meg_library).count = 0 then
				finished := True
			else
				Result := market_event_generation_library @ list_selection (
					meg_names (working_meg_library), concatenation (
						<<"Select a market analyzer for ", msg>>))
			end
		end

	one_or_two_market_function_selection: INTEGER is
		local
			c: CHARACTER
		do
			from
			until
				c /= '%U'
			loop
				print_list (<<"Would you like this analyzer to use one ",
							"or two technical indicators?%N",
							"     One (o) Two (t) ", eom>>)
				c := character_selection (Void)
				if not (c = 'o' or c = 'O' or c = 't' or c = 'T') then
					c := '%U'
					print_list (<<"Invalid selection: ", c, "%N">>)
				end
			end
			inspect
				c
			when 'o', 'O' then
				Result := One_value
			when 't', 'T' then
				Result := Two_value
			end
		end

	two_var_function_operator_selection (f: TVFA_FACTORY):
				RESULT_COMMAND [BOOLEAN] is
		local
			c: CHARACTER
		do
			from
			until
				c /= '%U'
			loop
				print_list (<<"Would you like to define an operator for this %
							%market analyzer? (y/n) ", eom>>)
				c := character_selection (Void)
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
							"function (", f.left_function.name,
							") or the right function (",
							f.right_function.name, ")? (l/r) ", eom>>)
					c := character_selection (Void)
					if not (c = 'l' or c = 'L' or c = 'r' or c = 'R') then
						c := '%U'
						print_list (<<"Invalid selection: ", c, "%N">>)
					end
				end
				if c = 'l' or c = 'L' then
					Result := operator_choice (f.left_function,
						two_var_exclude_cmds)
					use_left_function := true
				else
					check c = 'r' or c = 'R' end
					Result := operator_choice (f.right_function,
						two_var_exclude_cmds)
					use_left_function := false
				end
			end
		end

	function_choice (msg: STRING): MARKET_FUNCTION is
		do
			Result := function_library @ list_selection (function_names,
					concatenation (<<"Select the ", msg>>))
		end

	new_event_type_name_selection (names: LIST [STRING]): STRING is
		do
			from
			until
				Result /= Void
			loop
				if names.count > 0 then
					print_names_in_1_column (names, 1)
					print_list (<<"Type a name for the new event that does %
							%not match any of the above names:%N", eom>>)
				else
					print_list (<<"Type a name for the new event: ", eom>>)
				end
				read_line
				if names.has (last_string) then
					print_list (<<"%"", last_string,
								"%" matches one of the %
								%above names, please try again ...%N">>)
				else
					create Result.make (last_string.count)
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
				create names.make
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
				print_names_in_1_column (names, 1); print (eom)
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
				print_list (<<"Select specification for crossover detection:%N%
						%1) below-to-above%N2) above-to-below%N3) both%N",
						eom>>)
				inspect
					character_selection (Void)
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
					which, " the right analyzer? (y/n/h) ", eom>>)
				inspect
					character_selection (Void)
				when 'y', 'Y' then
					yes := True
					finished := True
				when 'n', 'N' then
					finished := True
				when 'h', 'H' then
					print (help @
						help.Compound_event_generator_time_extensions)
				else
					print ("Invalid response.%N")
				end
			end
			from
				if yes then
					finished := False
				end
			until
				finished
			loop
				print_list (<<"Select: days (d) months (m) years (y) End (e) ",
							eom>>)
				inspect
					character_selection (Void)
				when 'd', 'D' then
					print_list (<<"Enter the number of days: ", eom>>)
					read_integer
					days := last_integer
				when 'm', 'M' then
					print_list (<<"Enter the number of months: ", eom>>)
					read_integer
					months := last_integer
				when 'y', 'Y' then
					print_list (<<"Enter the number of years: ", eom>>)
					read_integer
					years := last_integer
				when 'e', 'E' then
					finished := True
				else
					print ("Invalid response.%N")
				end
				print_list (<<"Current settings: ", days, " days, ",
							months, " months, ", years, " years.%N">>)
			end
			if yes then
				create Result.make (years, months, days, 0, 0, 0)
				print ("Time extension added.%N")
			end
		end

	ceg_left_target_type: EVENT_TYPE is
			-- User's choice for the left target type (if any) of a
			-- compound event generator
		local
			finished, yes: BOOLEAN
			i: INTEGER
		do
			from
			until
				finished
			loop
				print_list (<<"Would you like to specify an event type ",
					"as target for the left analyzer's date/time? ",
					" (y/n/h) ", eom>>)
				inspect
					character_selection (Void)
				when 'y', 'Y' then
					yes := True
					finished := True
				when 'n', 'N' then
					finished := True
				when 'h', 'H' then
					print (help @
						help.Compound_event_generator_left_target_type)
				else
					print ("Invalid response.%N")
				end
			end
			if yes then
				Result := event_types @ list_selection (
					event_type_names, "Select an event type:")
			end
		end

	display_event_generator (eg: MARKET_EVENT_GENERATOR) is
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
				display_event_generator (compound_eg.left_analyzer)
				print ("Right sub-analyzer:%N")
				display_event_generator (compound_eg.right_analyzer)
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
				else
					print ("(No operator)%N")
				end
			end
			print_list (<<"(Hit <Return> to continue.) ", eom>>)
			read_line
		end

	help: HELP

feature {NONE} -- Implementation of hook routines

	do_initialize_lock is
		do
			lock := file_lock (file_name_with_app_directory (
				generators_file_name))
		end

end -- CL_BASED_MEG_EDITING_INTERFACE
