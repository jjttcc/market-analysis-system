indexing
	description:
		"Abstraction that allows the user to build MARKET_FUNCTIONs from %
		%the command line"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class CL_BASED_FUNCTION_EDITING_INTERFACE inherit

	COMMAND_LINE_UTILITIES [MARKET_FUNCTION]
		rename
			print_message as show_message
		export
			{NONE} all
			{ANY} input_device, output_device
		end

	FUNCTION_EDITING_INTERFACE
		undefine
			print
		end

creation

	make

feature -- Initialization

	make is
		do
			create operator_maker.make (false)
			create editor.make (Current, operator_maker)
		ensure
			editor_exists: editor /= Void
		end

feature -- Access

	operator_maker: CL_BASED_COMMAND_EDITING_INTERFACE

feature -- Status setting

	set_input_device (arg: IO_MEDIUM) is
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
			operator_maker.set_input_device (arg)
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
		ensure
			output_device_set: output_device = arg and output_device /= Void
		end

feature {NONE} -- Hook methods

	accepted_by_user (c: MARKET_FUNCTION): BOOLEAN is
		do
			print_list (<<"Select:%N     Print description of ",
						c.generator, "? (d)%N",
						"     Choose ", c.generator,
						" (c) Make another choice (a) ", eom>>)
			inspect
				character_selection (Void)
			when 'd', 'D' then
				print_list (<<"%N", function_description (c),
					"%N%NChoose ", c.generator,
						"? (y/n) ", eom>>)
				inspect
					character_selection (Void)
				when 'y', 'Y' then
					Result := true
				else
					check Result = false end
				end
			when 'c', 'C' then
				Result := true
			else
				check Result = false end
			end
		end

	list_selection_with_backout (l: LIST [STRING]; msg: STRING): INTEGER is
		local
			finished: BOOLEAN
		do
			from
				if l.count = 0 then
					finished := True
					Result := Exit_menu_value
					print ("There are no items to edit.%N")
				end
			until
				finished
			loop
				print_list (<<msg, " (0 to end):%N">>)
				print_names_in_1_column (l, 1); print (eom)
				read_integer
				if
					last_integer < 0 or
						last_integer > l.count
				then
					print_list (<<"Selection must be between 0 and ",
								l.count, "%N">>)
				elseif last_integer = 0 then
					finished := True
					Result := Exit_menu_value
				else
					check
						valid_index: last_integer > 0 and
									last_integer <= l.count
					end
					finished := True
					Result := last_integer
				end
			end
		end


end -- CL_BASED_FUNCTION_EDITING_INTERFACE
