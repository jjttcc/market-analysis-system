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

    poller: MEDIUM_POLLER

	socket_processor: CONNECTED_SOCKET_PROCESSOR

feature -- Status report

    expired: BOOLEAN
            -- Is Current no longer in use?

feature -- Basic operations

	execute (arg: ANY)
		do
			socket_processor.process_socket
            if socket_processor.interface.logged_out then
                final_cleanup
            else
                if socket_processor.error_occurred then
                    -- Assume no further processing of 'socket' is appropriate.
                    poller.remove_read_command(Current)
                end
            end
		end

    cleanup
            -- Cleanup before removal/destruction.
        do
            socket_processor.set_cleanup_after_execution(Current)
        end

feature {CONNECTED_SOCKET_PROCESSOR}

    final_cleanup
            -- Clean up for good: remove from poller queue and close the socket.
        do
            poller.remove_read_command(Current)
            socket.close
            expired := True
        end

end