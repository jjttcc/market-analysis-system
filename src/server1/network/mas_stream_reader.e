indexing

	description:
		"Command executed by the polling server when data is available %
		%for reading on the socket";
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class STREAM_READER

inherit

	TA_POLL_COMMAND
		redefine
			active_medium
		end

creation

	make

feature

	make (s: NETWORK_STREAM_SOCKET; fb: FACTORY_BUILDER) is
		require
			not_void: s /= Void and fb /= Void
		do
			pc_make (s)
			active_medium.listen (5)
			factory_builder := fb
			!!cl_interface.make (factory_builder)
			!!gui_interface.make (factory_builder)
		ensure
			set: active_medium = s and factory_builder = fb
		end

feature

	active_medium: NETWORK_STREAM_SOCKET
			-- The socket used for establishing a connection and creating
			-- io_socket

	io_socket: NETWORK_STREAM_SOCKET
			-- The socket that will be used for input and output

	is_gui: BOOLEAN
			-- Is the current client a GUI?

	cl_interface: MAIN_CL_INTERFACE

	gui_interface: MAIN_GUI_INTERFACE

	execute (arg: ANY) is
		local
			s: STRING
			finished: BOOLEAN
		do
			initialize
			if is_gui then
				gui_interface.set_io_medium (io_socket)
				interface := gui_interface
			else
				cl_interface.set_input_device (io_socket)
				cl_interface.set_output_device (io_socket)
				interface := cl_interface
			end
			-- When threads are added, this call will probably change to
			-- "interface.launch" to run in a separate thread.
			interface.execute
			io_socket.close
		end

	initialize is
		do
			active_medium.accept
			io_socket := active_medium.accepted
			io_socket.read_line
			print ("Received initial string from client: ")
			print (io_socket.last_string)
			-- Set factory_builder's io_medium to io_socket and read the
			-- the first few characters from the socket to find out if
			-- the connection is for a GUI or a command-line UI and create
			-- the corresponding type of "something-or-other" and give it
			-- to factory_builder.
			if io_socket.last_string.is_equal ("GUI") then
				is_gui := true
			else
				is_gui := false
			end
		end

end -- class STREAM_READER

