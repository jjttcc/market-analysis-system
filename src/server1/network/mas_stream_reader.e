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

	execute (arg: ANY) is
		local
			s: STRING
			finished: BOOLEAN
			mci: MAIN_CL_INTERFACE
			--mgi: MAIN_GUI_INTERFACE
		do
			initialize
--!!!The MAIN_GUI_INTERFACE will handle requests from the GUI client, using
--!!!the msgID of each message to determine the type of request.
			--NEW: if is_gui then
			--	!!mgi.make (factory_builder)
				--mgi.set_output_field_separator ("%T")
				--mgi.set_date_field_separator ("/")
				--interface := mgi
			--else
				!!mci.make (io_socket, io_socket, factory_builder)
				mci.set_output_field_separator ("%T")
				mci.set_date_field_separator ("/")
				interface := mci
			--end
			-- Set event coord?!!!
			-- When threads are added, this call will probably change to
			-- "interface.launch" to run in a separate thread.
			interface.execute
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

