note

    description: "POLL_COMMANDs whose `active_medium' is a connected socket"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    --settings: vim: expandtab:

class CONNECTED_SOCKET_POLL_COMMAND

inherit

    POLL_COMMAND
        rename
            active_medium as socket, make as pc_make
        redefine
            socket
        end

create

    make

feature {NONE} -- Initialization

	make (sproc: like socket_processor; p: MEDIUM_POLLER)
		require
			s_not_void: sproc /= Void
			tgt_socket_not_void: sproc.target_socket /= Void
        do
			socket_processor := sproc
			pc_make (socket_processor.target_socket)
            poller := p
            poller.put_read_command(Current)
        ensure
			socket_processor = sproc
			socket = socket_processor.target_socket
            poller = p
        end

feature -- Access

    socket: SOCKET

--!!!!!socket-enhancement: check if this is needed:
    poller: MEDIUM_POLLER

	socket_processor: CONNECTED_SOCKET_PROCESSOR

feature -- Basic operations

--!!!!!!refactor???
	execute (arg: ANY)
		do
--print("CONNECTED_SOCKET_POLL_COMMAND.execute calling " +
--"socket_processor.process_socket%N")
			socket_processor.process_socket
            if socket_processor.error_occurred then
                -- Assume no further processing of 'socket' is appropriate.
                poller.remove_read_command(Current)
            end
--!!!!!!!!!!???socket-enh:            poller.remove_read_command(Current)
		end

    cleanup
            -- Cleanup before removal/destruction.
        do
            socket_processor.set_cleanup_after_execution(Current)
--!!!!!!!!!old!!!!!!!!!!!
--            poller.remove_read_command(Current)
--            socket.close
--!!!!!!!!!end: old!!!!!!!!!!!
        end

--!!!!!!![socket-enh]Note: refactoring needed: new CONNECTED_SOCKET_PROCESSOR
--!!!!!!!class in eiffel_library and in finance/mas:
--!!!!!!!!CONNECTED_SOCKET_PROCESSOR -> MAS_CONNECTED_SOCKET_PROCESSOR
feature {CONNECTED_SOCKET_PROCESSOR}

    final_cleanup
            -- Clean up for good: remove from poller queue and close the socket.
        do
print("CONNECTED_SOCKET_POLL_COMMAND.final_cleanup was called")
print(" - removing from poller and closing socket.%N")
            poller.remove_read_command(Current)
            socket.close
        end

end
