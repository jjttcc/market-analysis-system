note
	description:
		"Abstraction that allows the user to build MARKET_FUNCTIONs from %
		%the command line"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CL_BASED_FUNCTION_EDITING_INTERFACE inherit

	MAS_COMMAND_LINE_UTILITIES
		rename
			print_message as show_message
		export
			{ANY} input_device, output_device
		end

	FUNCTION_EDITING_INTERFACE
		undefine
			print
		redefine
			help, end_save
		end

	TERMINABLE
		export
			{NONE} all
		undefine
			print
		end

	GLOBAL_SERVER_FACILITIES
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

	make (dispenser: TRADABLE_DISPENSER)
		do
			create operator_maker.make (False)
			create editor.make (Current, operator_maker)
			create help.make
			register_for_termination (Current)
			tradable_dispenser := dispenser
		ensure
			editor_exists: editor /= Void
		end

feature -- Status setting

	set_input_device (arg: IO_MEDIUM)
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
			operator_maker.set_input_device (arg)
		ensure
			input_device_set: input_device = arg and input_device /= Void
		end

	set_output_device (arg: IO_MEDIUM)
			-- Set output_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_device := arg
			operator_maker.set_output_device (arg)
		ensure
			output_device_set: output_device = arg and output_device /= Void
		end

feature {NONE} -- Implementation

	help: HELP

	operator_maker: CL_BASED_COMMAND_EDITING_INTERFACE

	tradable_dispenser: TRADABLE_DISPENSER

feature {NONE} -- Implementation of hook methods

	main_indicator_edit_selection: INTEGER
		local
			msg: STRING
		do
			check
				io_devices_not_void: input_device /= Void and
					output_device /= Void
			end
			if not dirty or not ok_to_save then
				msg := concatenation (<<"Select action:",
					"%N     Create a new indicator (c) %
					%Remove an indicator (r) %N%
					%     View an indicator (v) %
					%Edit an indicator (e) %
					%Previous (-) ", eom>>)
			else
				msg := concatenation (<<"Select action:",
					"%N     Create a new indicator (c) %
					%Remove an indicator (r) %N%
					%     View an indicator (v) %
					%Edit an indicator (e) %
					%Save changes (s) %N%
					%     Previous - abort changes (-) ", eom>>)
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
				when '!' then
					execute_shell_command
				when '-' then
					Result := Exit_value
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	accepted_by_user (c: MARKET_FUNCTION): BOOLEAN
		do
			print_list (<<"Select:%N     Print description of ",
						c.generator + name_for (c), "? (d)%N",
						"     Choose ", c.generator + name_for (c),
						" (c) Make another choice (a) ", eom>>)
			inspect
				character_selection (Void)
			when 'd', 'D' then
				print_list (<<"%N", function_description (c),
					"%N%NChoose ", c.generator + name_for (c),
						"? (y/n) ", eom>>)
				inspect
					character_selection (Void)
				when 'y', 'Y' then
					Result := True
				else
					check Result = False end
				end
			when 'c', 'C' then
				Result := True
			else
				check Result = False end
			end
		end

	list_selection_with_backout (l: LIST [STRING]; msg: STRING): INTEGER
		do
			Result := backoutable_selection (l, msg, Exit_value)
		end

	do_initialize_lock
		do
			lock := file_lock (file_name_with_app_directory (
				indicators_file_name, False))
		end

	end_save
		do
			-- Ensure current changes show up in the tradable_dispenser by
			-- clearing its caches.
			if tradable_dispenser /= Void then
				tradable_dispenser.clear_caches
			end
		end

	display_operator_tree (op: COMMAND)
		do
			operator_maker.print_command_tree (op, 1)
		end

end -- CL_BASED_FUNCTION_EDITING_INTERFACE
