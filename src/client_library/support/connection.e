-- Provides socket connection facilities for Market Analysis command-line
-- clients.


--!!!NOTE: This class can perhaps be replaced by CLIENT_CONNECTION from MCT.
class CONNECTION inherit

	PROTOCOL

create

	make

feature -- Feature comment


	make (host: STRING; port: INTEGER) is
			-- Create socket, connect to host, and send initial request.
		local
			verbose: BOOLEAN
		do
			create socket.make_client_by_port (port, host)
			socket.connect
			if verbose then print ("Connected to " + host) end
			termination_requested := False
			last_message := ""
			-- Notify server that this is a command-line client.
			send_message(Command_line)
		end

	termination_requested: BOOLEAN

	last_message: STRING

	receive_message is
			-- Receive the last requested message, put result in last_message.
		local
			finished: BOOLEAN
--!!Check if correct type:
			msg: STRING
			c: STRING
		do
			last_message := ""
			msg := ""
			from
			until
				finished
			loop
--!!!Fix:				c := socket.recv(Buffersize)
				if c = EOM or c = EOF then
					finished := True
				end
				msg.append(c)
			end
			if c = EOF then
				termination_requested := True
			end
--!!!Fix:			last_message := join(msg, "")
		end

	send_message (msg: STRING) is
		do
			socket.put_string (msg)
		end

	close is
			-- Close the connection.
		do
			socket.close()
		end

	Buffersize: INTEGER is 1

	socket: NETWORK_STREAM_SOCKET

end
