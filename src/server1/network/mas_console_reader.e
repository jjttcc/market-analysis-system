indexing

	description:
		"Command executed by the polling server when data is available %
		%for reading on the console";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CONSOLE_READER

inherit

	MA_POLL_COMMAND
		rename
			active_medium as output_device
		redefine
			output_device, interface
		end

creation

	make

feature -- Initialization

	make (fb: FACTORY_BUILDER) is
		require
			not_void: fb /= Void
		do
			input_device := io.input
			output_device := io.output
			factory_builder := fb
			create interface.make_io (input_device, output_device,
				factory_builder)
			-- Input from the user is needed to trigger the MEDIUM_POLLER.
			output_device.put_string (
				"Welcome to the Market Analysis Server console! %
				%(Hit <Enter> to continue)%N")
		ensure
			set: input_device = io.input and output_device = io.output and
					factory_builder = fb
		end

feature

	output_device, input_device: PLAIN_TEXT_FILE
			-- input and output consoles

	interface: MAIN_CL_INTERFACE

	execute (arg: ANY) is
		do
			-- When threads are added, this call will probably change to
			-- "interface.launch" to run in a separate thread.
			interface.main_menu
		end

end -- class CONSOLE_READER

