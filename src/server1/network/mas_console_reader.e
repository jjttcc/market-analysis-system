indexing

	description:
		"Command executed by the polling server when data is available %
		%for reading on the console";

	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class CONSOLE_READER

inherit

	TA_POLL_COMMAND
		rename
			active_medium as output_device
		redefine
			output_device
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
			-- Input from the user is needed to trigger the MEDIUM_POLLER.
			output_device.put_string (
				"Welcome to the TA Server console! (Hit <Enter> to continue)%N")
		ensure
			set: input_device = io.input and output_device = io.output and
					factory_builder = fb
		end

feature

	output_device, input_device: PLAIN_TEXT_FILE
			-- input and output consoles

	execute (arg: ANY) is
		local
			s: STRING
			finished: BOOLEAN
			mci: MAIN_CL_INTERFACE
		do
			!!factory_builder.make
			!!mci.make (input_device, output_device,
												factory_builder)
			mci.set_output_field_separator ("%T")
			mci.set_date_field_separator ("/")
			interface := mci
			-- When threads are added, this call will probably change to
			-- "interface.launch" to run in a separate thread.
			interface.execute
		end

end -- class CONSOLE_READER

