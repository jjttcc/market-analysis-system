indexing
	description: "Root class for the Market Analysis Server using MAL"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MA_SERVER inherit

	GLOBAL_SERVER
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

GLOBAL_SERVICES

creation

	make

feature -- Initialization

	make is
		local
			socket: NETWORK_STREAM_SOCKET
			readcmd: POLL_COMMAND
			i: INTEGER
			factory_builder: FACTORY_BUILDER
			version: expanded PRODUCT_INFO
		do
			if command_line_options.help then
				command_line_options.usage
			elseif command_line_options.version_request then
				print_list (<<version.name, ", Version ", version.number, ", ",
					version.informal_date, "%N">>)
			else
				!!poller.make_read_only
				!!factory_builder.make
				!LINKED_LIST [SOCKET]!current_sockets.make
				-- Make a socket for each port number provided in the
				-- command line, create a STREAM_READER to handle it,
				-- and add it to the poller's list of read commands.
				-- (Allows concurrent processing - in a future version.)
				from
					command_line_options.port_numbers.start
				until
					command_line_options.port_numbers.exhausted
				loop
					!!socket.make_server_by_port (
						command_line_options.port_numbers.item)
					!STREAM_READER!readcmd.make (socket, factory_builder)
					poller.put_read_command (readcmd)
					current_sockets.extend (socket)
					command_line_options.port_numbers.forth
				end
				-- If background is not specified, add a reader to respond to
				-- console commands.
				if not command_line_options.background then
					!CONSOLE_READER!readcmd.make (factory_builder)
					poller.put_read_command (readcmd)
				end
				from
				until
					finished
				loop
					poller.execute (15, 20000)
				end
				close_sockets
			end
		rescue
			close_sockets
		end

feature {NONE}

	finished: BOOLEAN
			-- Is it time to exit the server?

	poller: MEDIUM_POLLER
			-- Poller for client socket connections

	close_sockets is
			-- Close all unclosed sockets.
		do
			if current_sockets /= Void then
				from
					current_sockets.start
				until
					current_sockets.exhausted
				loop
					if not current_sockets.item.is_closed then
						current_sockets.item.close
					end
					current_sockets.forth
				end
			end
		end

	current_sockets: LIST [SOCKET]

testmfline is
local
	date1, date2: DATE_TIME
	startp, endp, p: MARKET_POINT
	line: MARKET_FUNCTION_LINE
	i: INTEGER
do
	!!date1.make (1999, 2, 2, 0, 0, 0); !!date2.make (1999, 2, 8, 0, 0, 0)
	!!startp.make; !!endp.make
	startp.set_x_y_date (1, 50, date1); endp.set_x_y_date (7, 61, date2)
	!!line.make_from_2_points (startp, endp, period_types @ "daily")
	from
		line.output.start
		i := 1
	until
		i = 100
	loop
		p := line.output.item
print_list (<<"i: ", i, ", p.x: ", p.x, ", p.y: ", p.y, ", p.date", p.date_time, "%N">>)
		i := i + 1
		line.output.forth
	end
	line.make (startp, 0.01, period_types @ "weekly")
	from
		line.output.start
		i := 1
	until
		i = 100
	loop
		p := line.output.item
print_list (<<"i: ", i, ", p.x: ", p.x, ", p.y: ", p.y, ", p.date", p.date_time, "%N">>)
		i := i + 1
		line.output.forth
	end
 end
end -- MA_SERVER
