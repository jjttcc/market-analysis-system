indexing

	description:
		"Command executed by the polling server when data is available %
		%for reading on the socket";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class STREAM_READER

inherit

	MA_POLL_COMMAND
		redefine
			active_medium
		end

	CLEANUP_SERVICES
		export
			{NONE} all
		end

	TERMINABLE
		export
			{NONE} all
		end

creation

	make

feature

	make (s: COMPRESSED_SOCKET; fb: FACTORY_BUILDER) is
		require
			not_void: s /= Void and fb /= Void
		do
			pc_make (s)
			active_medium.listen (5)
			factory_builder := fb
			create cl_interface.make (factory_builder)
			create gui_interface.make (factory_builder)
			register_for_termination (Current)
		ensure
			set: active_medium = s and factory_builder = fb
		end

feature

	active_medium: COMPRESSED_SOCKET
			-- The socket used for establishing a connection and creating
			-- io_socket

	io_socket: COMPRESSED_SOCKET
			-- The socket that will be used for input and output

	is_gui: BOOLEAN
			-- Is the current client a GUI?

	cl_interface: MAIN_CL_INTERFACE

	gui_interface: MAIN_GUI_INTERFACE

	execute (arg: ANY) is
		do
			initialize
			if is_gui then
				gui_interface.set_io_medium (io_socket)
				interface := gui_interface
			else
				io_socket.set_compression (false)
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
			io_socket.read_character
			if io_socket.last_character.is_equal (Console_flag) then
				is_gui := false
			else
				is_gui := true
			end
		end

feature {NONE}

	cleanup is
		do
			if io_socket /= Void and then not io_socket.is_closed then
				if not is_gui then
					terminate_command_line_client
				end
				io_socket.close
			end
		end

	terminate_command_line_client is
		local
			constants: expanded APPLICATION_CONSTANTS
		do
			io_socket.put_character (constants.End_of_file_character)
		end

	Console_flag: CHARACTER is 'C'

end -- class STREAM_READER
