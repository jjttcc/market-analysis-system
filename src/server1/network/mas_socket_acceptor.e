note

	description:
		"SOCKET_ACCEPTORs dedicated to processing MAS requrests"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MAS_SOCKET_ACCEPTOR

inherit

	SOCKET_ACCEPTOR
		rename
			persistent_connection_flag as Console_flag
		undefine
			process_socket
		redefine
			server_socket, accepted_socket, prepare_for_persistent_connection,
			initialize_for_execution
		end

	MA_COMMUNICATION_PROTOCOL
		export
			{NONE} all
		end

	THREAD
		rename
			launch as process_socket
		end

creation

	make

feature

	make (s: COMPRESSED_SOCKET; fb: GLOBAL_OBJECT_BUILDER)
		require
			not_void: s /= Void and fb /= Void
		do
			initialize_components (s)
			factory_builder := fb
		ensure
			set: server_socket = s and factory_builder = fb
		end

feature -- Access

	server_socket: COMPRESSED_SOCKET
			-- The socket used for establishing a connection and creating
			-- accepted_socket

	accepted_socket: COMPRESSED_SOCKET
			-- The socket that will be used for input and output

	factory_builder: GLOBAL_OBJECT_BUILDER
			-- Builder of objects used by for input processing

feature {NONE} -- Hook routine Implementations

	prepare_for_persistent_connection
		do
			accepted_socket.set_compression (False)
		end

	connection_termination_character: CHARACTER
		note
			once_status: global
		local
			constants: expanded APPLICATION_CONSTANTS
		once
			Result := constants.End_of_file_character
		end

	initialize_for_execution
		do
			persistent_connection_interface :=
				factory_builder.persistent_connection_interface
			non_persistent_connection_interface :=
				factory_builder.non_persistent_connection_interface
			Precursor
		end

feature {NONE} -- Unused

	Message_date_field_separator: STRING = ""

	Message_time_field_separator: STRING = ""

end
