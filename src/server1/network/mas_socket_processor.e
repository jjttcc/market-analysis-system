note

    description:
        "SERVER_SOCKET_PROCESSORs dedicated to processing MAS requests"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    --settings: vim: expandtab:

class MAS_SOCKET_PROCESSOR

inherit

    SERVER_SOCKET_PROCESSOR
        rename
            persistent_connection_flag as Console_flag
        undefine
            process_socket
        redefine
            server_socket, target_socket, prepare_for_persistent_connection,
            post_process
        end

    THREAD
        rename
            launch as process_socket
        end

inherit {NONE}

    MA_COMMUNICATION_PROTOCOL

creation

    make

feature

    make (s: COMPRESSED_SOCKET; fb: GLOBAL_OBJECT_BUILDER; p: MEDIUM_POLLER)
        require
            not_void: s /= Void and fb /= Void and p /= Void
        do
print("I am the MAS_SOCKET_PROCESSOR and I'm very much hoping that there")
print("is only%None of me.  Is this true?%N")
            initialize
            server_socket := s
            factory_builder := fb
            poller := p
        ensure
            set: server_socket = s and factory_builder = fb and poller = p
        end


feature -- Access

    server_socket: COMPRESSED_SOCKET
            -- The socket used for establishing a connection and creating
            -- accepted_socket

    target_socket: COMPRESSED_SOCKET
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
            target_socket.set_compression (False)
        end

    connection_termination_character: CHARACTER
        note
            once_status: global
        local
            constants: expanded APPLICATION_CONSTANTS
        once
            Result := constants.End_of_file_character
        end

    initialize_interfaces
        do
            if persistent_connection_interface = Void then
                persistent_connection_interface :=
                    factory_builder.persistent_connection_interface
            end
            if non_persistent_connection_interface = Void then
                non_persistent_connection_interface :=
                    factory_builder.non_persistent_connection_interface
            end
        end

    post_process
            -- Perform any processing needed after calling `do_execute'.
        local
            poll_cmd: CONNECTED_SOCKET_POLL_COMMAND
            sock_proc: CONNECTED_SOCKET_PROCESSOR
            app_constants: expanded APPLICATION_CONSTANTS
        do
            if close_after_each_response then
--!!!!!!!!
print("post_process: closing socket%N")
                Precursor
            else
                if connection_cache = Void then
                    create connection_cache.make(
                        app_constants.default_connection_cache_size)
--!!!!!Forced artificial test:
create connection_cache.make(1)
                end
                create sock_proc.make(target_socket, factory_builder, poller)
                create poll_cmd.make(sock_proc, poller)
                connection_cache.add(poll_cmd)
            end
        end

--!!!![socket-enh]!!!!!!!Put this in the right place:
log_socket_error(msg: STRING)
do
    io.error.print(msg)
end

    perform_specific_error_processing
        do
--!!!!!!!!!TBD:
io.error.print("MAS_SOCKET_PROCESSOR.perform_specific_error_processing...%N")
        end

------------------------------------------------------------------------
--    read_command_for (medium: SOCKET): POLL_COMMAND
--        local
--            sock_proc: MAS_SOCKET_PROCESSOR
--            appenv: expanded APP_ENVIRONMENT
--        do
--            if attached {COMPRESSED_SOCKET} medium as socket then
--                create sock_proc.make (socket, factory_builder, poller)
----!!!!!socket-enh
--            sock_proc.close_after_each_response :=
--                not appenv.no_close_after_each_send
--            -- (sock_proc.close_after_each_response is true iff the "no-close"
--            -- environment variable is not set.)
--            else
--                raise ("cast of " + medium.generating_type + " failed " +
--                    "in MA_SERVER.read_command_for")
--            end
--            create {LISTENING_SOCKET_POLL_COMMAND} Result.make(sock_proc)
--        end
------------------------------------------------------------------------

feature {NONE} -- Implementation

    connection_cache: CONNECTION_CACHE

feature {NONE} -- Unused

    Message_date_field_separator: STRING = ""

    Message_time_field_separator: STRING = ""

end
