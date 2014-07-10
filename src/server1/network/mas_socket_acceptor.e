note

    description:
        "SOCKET_ACCEPTORs dedicated to processing MAS requrests"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    --settings: vim: expandtab:

class MAS_SOCKET_ACCEPTOR

inherit

    SOCKET_ACCEPTOR
        rename
            persistent_connection_flag as Console_flag
        undefine
            process_socket
        redefine
            server_socket, accepted_socket, prepare_for_persistent_connection,
            initialize_for_execution, post_process
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

    make (s: COMPRESSED_SOCKET; fb: GLOBAL_OBJECT_BUILDER; p: MEDIUM_POLLER)
        require
            not_void: s /= Void and fb /= Void
        do
            initialize_components (s)
            factory_builder := fb
            poller := p
        ensure
            set: server_socket = s and factory_builder = fb and poller = p
        end

feature -- Access

    server_socket: COMPRESSED_SOCKET
            -- The socket used for establishing a connection and creating
            -- accepted_socket

    accepted_socket: COMPRESSED_SOCKET
            -- The socket that will be used for input and output

    factory_builder: GLOBAL_OBJECT_BUILDER
            -- Builder of objects used by for input processing

    poller: MEDIUM_POLLER

feature -- Status report

--!!!!!![14.05]This needs to be configurable (e.g., with env. var)!!!!!!!!:
    close_after_each_response: BOOLEAN assign set_close_after_each_response
            -- Should 'accepted_socket' be closed after each sent response?

feature -- Status setting

    set_close_after_each_response(value: BOOLEAN)
        do
            close_after_each_response := value
        end

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

    post_process
            -- Perform any processing needed after calling `do_execute'.
        local
            poll_cmd: CONNECTED_SOCKET_POLL_COMMAND
        do
            if close_after_each_response then
--!!!!!!!!
print("post_process: closing socket%N")
                Precursor
            else
                create poll_cmd.make(accepted_socket, poller)
            end
        end

feature {NONE} -- Unused

    Message_date_field_separator: STRING = ""

    Message_time_field_separator: STRING = ""

end
