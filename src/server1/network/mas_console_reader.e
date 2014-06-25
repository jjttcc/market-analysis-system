note

	description:
		"Command executed by the polling server when data is available %
		%for reading on the console";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MAS_CONSOLE_READER

inherit

	CONSOLE_READER
		rename
			make as cr_make
		end

creation

	make

feature -- Initialization

	make (fb: GLOBAL_OBJECT_BUILDER)
		require
			not_void: fb /= Void
		do
			initialize
			factory_builder := fb
			create interface.make_io (input_device, output_device,
				factory_builder)
			interface.set_console
			-- Input from the user is needed to trigger the MEDIUM_POLLER.
			output_welcome_message
		ensure
			set: input_device = io.input and output_device = io.output and
					factory_builder = fb
		end

feature -- Access

	interface: MAIN_CL_INTERFACE

	factory_builder: GLOBAL_OBJECT_BUILDER

feature -- Basic operations

	execute (arg: ANY)
		do
			-- When threads are added, this call will probably change to
			-- "interface.launch" to run in a separate thread.
			interface.main_menu
		end

feature {NONE} -- Hook routine Implementations

	welcome_message: STRING = "Welcome to the Market Analysis Server console!"

end
