note

    description:
        "SOCKET_PROCESSORs dedicated to processing MAS requests with a %
        %socket that keeps its connection open"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    --settings: vim: expandtab:

class CONNECTED_SOCKET_PROCESSOR

inherit

    SOCKET_PROCESSOR
        rename
            persistent_connection_flag as Console_flag
        undefine
            process_socket
        redefine
            target_socket, post_process, non_persistent_connection_interface
        end

    THREAD
        rename
            launch as process_socket
        end

inherit {NONE}

    MA_COMMUNICATION_PROTOCOL

creation

    make

feature -- Initialization

--!!!![socket-enh]!!!!!!!Put this in the right place:
log_socket_error(msg: STRING)
do
    io.error.print(msg)
end

    make(s: COMPRESSED_SOCKET; fb: GLOBAL_OBJECT_BUILDER; p: MEDIUM_POLLER)
        require
            not_void: s /= Void and fb /= Void and p /= Void
        do
--!!!!reminder: refactor [socket-enh]
print("I am a CONNECTED_SOCKET_PROCESSOR and there could be more than")
print(" one of me.%N")
            initialize
            target_socket := s
            factory_builder := fb
            poller := p
        ensure
            set: target_socket = s and factory_builder = fb and poller = p
        end


feature -- Access

    target_socket: COMPRESSED_SOCKET
            -- The socket that will be used for input and output

    factory_builder: GLOBAL_OBJECT_BUILDER
            -- Builder of objects used by for input processing

    poller: MEDIUM_POLLER

    non_persistent_connection_interface: MAIN_GUI_INTERFACE

feature {CONNECTED_SOCKET_POLL_COMMAND}

    set_cleanup_after_execution(pcmd: CONNECTED_SOCKET_POLL_COMMAND)
            -- Set post_process_cleanup_target for final cleanup.
        require
            pcmd_not_void: pcmd /= Void
        do
--!!!!!![socket-enh]
print("set_cleanup_after_execution called by " + pcmd.out + "%N")
            post_process_cleanup_target := pcmd
            if non_persistent_connection_interface = Void then
--!!!!!![socket-enh]
print("set_cleanup_after_execution: 'non_persistent_connection_interface' ")
print("was Void - fixing...%N")
                initialize_interfaces
            end
            -- Tell this interface to (once) operate in "socket will be
            -- closed after (response) command execution" mode.
            non_persistent_connection_interface.set_close_socket
        ensure
            ppct_set: post_process_cleanup_target = pcmd
        end

    post_process_cleanup_target: CONNECTED_SOCKET_POLL_COMMAND

feature {NONE} -- Hook routine Implementations

--!!!!reminder: refactor [socket-enh]
    connection_termination_character: CHARACTER
        note
            once_status: global
        local
            constants: expanded APPLICATION_CONSTANTS
        once
            Result := constants.End_of_file_character
        end

--!!!!reminder: refactor [socket-enh]
    initialize_interfaces
        local
            non_pint: NON_PERSISTENT_CONNECTION_INTERFACE
        do
            if persistent_connection_interface = Void then
                persistent_connection_interface :=
                    factory_builder.persistent_connection_interface
            end
            if non_persistent_connection_interface = Void then
                non_pint := factory_builder.non_persistent_connection_interface
                if attached {MAIN_GUI_INTERFACE} non_pint as gui_if then
--!!!!!remove: non_persistent_connection_interface := gui_if
                    -- Avoid possible race condition with respect to this
                    -- interface object and other POLL_COMMANDs/SOCKETs:
                    non_persistent_connection_interface := gui_if.twin
                end
            end
        end

    post_process
        do
            if post_process_cleanup_target /= Void then
                post_process_cleanup_target.final_cleanup
            end
        end

    perform_specific_error_processing
        do
--!!!!!!!!! - remove this procedure, I think - !!!!!!!!!!!!!!!!!!
io.error.print("CONNECTED_SOCKET_PROCESSOR.perform_specific_error_processing...%N")
        end

feature {NONE} -- Unused

--!!!!reminder: refactor [socket-enh]
    Message_date_field_separator: STRING = ""

    Message_time_field_separator: STRING = ""

end
