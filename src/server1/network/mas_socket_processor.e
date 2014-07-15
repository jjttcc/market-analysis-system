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
            if is_non_persistent_connection then
                if non_persistent_connection_interface = Void then
                    non_persistent_connection_interface :=
                        factory_builder.non_persistent_connection_interface
                end
            else
                if persistent_connection_interface = Void then
                    persistent_connection_interface :=
                        factory_builder.persistent_connection_interface
                end
            end
        end

    post_process
            -- Perform any processing needed after calling `do_execute'.
        local
            poll_cmd: CONNECTED_SOCKET_POLL_COMMAND
            sock_proc: CONNECTED_SOCKET_PROCESSOR
            app_constants: expanded APPLICATION_CONSTANTS
            app_env: expanded APP_ENVIRONMENT
            cache_size: INTEGER
        do
            if
                not is_non_persistent_connection or
                close_after_each_response
            then
                Precursor
            else
                check
                    non_persistent: is_non_persistent_connection
                end
                if connection_cache = Void then
                    cache_size := app_env.connection_cache_size
                    if cache_size <= 0 then
                        cache_size :=
                            app_constants.default_connection_cache_size
                    end
                    create connection_cache.make(cache_size)
                end
                create sock_proc.make(target_socket, factory_builder, poller)
                create poll_cmd.make(sock_proc, poller)
                connection_cache.add(poll_cmd)
            end
        end

feature {NONE} -- Implementation

    connection_cache: CONNECTION_CACHE

feature {NONE} -- Unused

    Message_date_field_separator: STRING = ""

    Message_time_field_separator: STRING = ""

end
