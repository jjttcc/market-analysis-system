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
            target_socket, non_persistent_connection_interface,
            termination_required
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

    make(s: COMPRESSED_SOCKET; fb: GLOBAL_OBJECT_BUILDER; p: MEDIUM_POLLER)
        require
            not_void: s /= Void and fb /= Void and p /= Void
        do
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

feature {NONE} -- Hook routine Implementations

    termination_required: BOOLEAN = False

    connection_termination_character: CHARACTER
        note
            once_status: global
        local
            constants: expanded APPLICATION_CONSTANTS
        once
            Result := constants.End_of_file_character
        end

    initialize_interfaces
        local
            non_pint: NON_PERSISTENT_CONNECTION_INTERFACE
        do
            if is_non_persistent_connection then
                if non_persistent_connection_interface = Void then
                    non_pint :=
                        factory_builder.non_persistent_connection_interface
                    if attached {MAIN_GUI_INTERFACE} non_pint as gui_if then
                        -- Avoid possible race condition with respect to this
                        -- interface object and other POLL_COMMANDs/SOCKETs:
                        non_persistent_connection_interface := gui_if.twin
                    end
                end
            else
                if persistent_connection_interface = Void then
                    persistent_connection_interface :=
                        factory_builder.persistent_connection_interface
                end
            end
        end

feature {NONE} -- Unused

    Message_date_field_separator: STRING = ""

    Message_time_field_separator: STRING = ""

end
