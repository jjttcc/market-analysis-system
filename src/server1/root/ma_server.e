indexing
	description: "Root class for TA application server using TAL"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TA_SERVER

creation

	make

feature -- Initialization

	make (argv: ARRAY [STRING]) is
		local
			socket: NETWORK_STREAM_SOCKET
			readcmd: POLL_COMMAND
			i: INTEGER
			factory_builder: FACTORY_BUILDER
		do
			!!poller.make_read_only
			!!factory_builder.make
			--!!!Decide what to do about CL args - should the fb process
			-- all of them, including the socket port numbers, or should
			-- a new class do all CL processing, or ??? - Perhaps use
			-- one of the free Eiffel Forum CL parsing libraries.
			!CONSOLE_READER!readcmd.make (factory_builder)
			poller.put_read_command (readcmd)
			-- Make a socket for each port number provided in the
			-- command line, create a STREAM_READER to handle it,
			-- and add it to the poller's list of read commands.
			-- (Allows concurrent processing - in a future version.)
			from
				i := 1
			until
				i = argv.upper + 1 or else not (argv @ i).is_integer
			loop
				!!socket.make_server_by_port (
					argv.item (i).to_integer)
				!STREAM_READER!readcmd.make (socket, factory_builder)
				poller.put_read_command (readcmd)
				i := i + 1
			end
			from
			until
				finished
			loop
				poller.execute (15, 20000)
			end
			close_sockets
		rescue
			close_sockets
		end

feature {NONE}

	finished: BOOLEAN
			-- Is it time to exit the server?

	poller: MEDIUM_POLLER
			-- Poller for client socket connections

	close_sockets is
			-- Close all sockets added to `poller'.
		do
			-- If sockets aren't closed, close them.
			-- TBI
		end

end -- TA_SERVER
