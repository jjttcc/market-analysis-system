indexing
	description:
		"Abstraction that allows the user to build MARKET_FUNCTIONs from %
		%the command line"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class CL_BASED_FUNCTION_EDITING_INTERFACE inherit

	COMMAND_LINE_UTILITIES [MARKET_FUNCTION]
		rename
			print_message as show_message
		export
			{NONE} all
		end

	PRINTING
		export
			{NONE} all
		undefine
			print
		end

	FUNCTION_EDITING_INTERFACE
		undefine
			print
		end

creation

	make

feature -- Initialization

	make (input_dev, output_dev: IO_MEDIUM) is
		require
			not_void: input_dev /= Void and output_dev /= Void
		local
			op_maker: CL_BASED_COMMAND_EDITING_INTERFACE
		do
			set_input_device (input_dev)
			set_output_device (output_dev)
			!!op_maker.make (input_dev, output_dev)
			!!editor.make (Current, op_maker)
		ensure
			iodev_set: input_device = input_dev and output_device = output_dev
			editor_exists: editor /= Void
		end

feature {NONE} -- Hook methods

	accepted_by_user (c: MARKET_FUNCTION): BOOLEAN is
		do
			print_list (<<"Select:%N     Print description of ",
						c.generator, "? (d)%N",
						"     Choose ", c.generator,
						" (c) Make another choice (a) ">>)
			inspect
				selected_character
			when 'd', 'D' then
				print_list (<<"%N", function_description (c),
					"%N%NChoose ", c.generator,
						"? (y/n) ">>)
				inspect
					selected_character
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

end -- CL_BASED_FUNCTION_EDITING_INTERFACE
