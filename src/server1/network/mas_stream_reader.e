indexing

	description:
		"Command executed by the polling server when data is available %
		%for reading on the socket";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_STREAM_READER

inherit

	MA_POLL_COMMAND

	STREAM_READER
		rename
			persistent_connection_flag as Console_flag
		redefine
			active_medium, io_socket,
			prepare_for_persistent_connection, interface
		end

	MA_COMMUNICATION_PROTOCOL
		export
			{NONE} all
		end

creation

	make

feature

	make (s: COMPRESSED_SOCKET; fb: GLOBAL_OBJECT_BUILDER) is
		require
			not_void: s /= Void and fb /= Void
		do
			initialize_components (s)
			factory_builder := fb
			persistent_connection_interface :=
				factory_builder.persistent_connection_interface
			non_persistent_connection_interface :=
				factory_builder.non_persistent_connection_interface
		ensure
			set: active_medium = s and factory_builder = fb
		end

feature -- Access

	active_medium: COMPRESSED_SOCKET
			-- The socket used for establishing a connection and creating
			-- io_socket

	io_socket: COMPRESSED_SOCKET
			-- The socket that will be used for input and output

	interface: MAIN_APPLICATION_INTERFACE

feature {NONE} -- Hook routine Implementations

	prepare_for_persistent_connection is
		do
			io_socket.set_compression (False)
		end

	connection_termination_character: CHARACTER is
		local
			constants: expanded APPLICATION_CONSTANTS
		once
			Result := constants.End_of_file_character
		end

feature {NONE} -- Unused

	Message_date_field_separator: STRING is ""

	Message_time_field_separator: STRING is ""

end
