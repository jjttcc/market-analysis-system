indexing
	description: "Utility routines for socket-based connections"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CONNECTION_UTILITIES inherit

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	initial_sleep_micro_seconds: INTEGER is
			-- Number of microseconds to sleep before the first try with
			-- `server_connection_attempts'
		once
			Result := 250000
		end

	sleep_micro_seconds: INTEGER is
			-- Number of microseconds to sleep in between tries with
			-- `server_connection_attempts'
		once
			Result := 550000
		end

feature -- Basic operations

	server_connection_attempts (host, port: STRING; tries: INTEGER): STRING is
			-- The result of `tries' attempts to "ping" the server
			-- specified by `host' and `port' - Void if the ping succeeds;
			-- otherwise a description of the problem
		require
			args_exist: host /= Void and port /= Void
			at_least_one_try: tries > 0
		local
			i: INTEGER
		do
			from
print ("csa connecting on port " + port + " (" + i.out + ")...%N")
				microsleep (0, initial_sleep_micro_seconds)
				Result := server_connection_diagnosis (host, port)
				i := 1
				check i <= tries end
			until
				Result = Void or i = tries
			loop
				microsleep (0, sleep_micro_seconds)
print ("csa connecting on port " + port + " (" + i.out + ")...%N")
				Result := server_connection_diagnosis (host, port)
				i := i + 1
			end
		end

	server_connection_diagnosis (host, port: STRING): STRING is
			-- Diagnosis of attempt to "ping" the server specified by
			-- `host' and `port' - Void if the ping succeeds;
			-- otherwise a description of the problem
		require
			args_exist: host /= Void and port /= Void
		local
			connection: GUI_CLIENT_CONNECTION
			retried: BOOLEAN
		do
			if not retried then
				if not port.is_integer then
					Result := "Invalid port number: " + port
				end
				if Result = Void then
					create connection.make (host, port.to_integer)
					if connection.last_communication_succeeded then
						connection.ping_server
						if not connection.last_communication_succeeded then
							Result := "Communication with server (host: " +
							host + ", port; " + port + ") failed:%N" +
							connection.error_report + "."
						end
					else
						Result := "Could not connect to server at host: " +
							host + ", port: " + port
						if not connection.error_report.is_empty then
							Result.append ("%N(" +
								connection.error_report + ").")
						end
					end
				end
			else
				Result := "Could not connect to server at host: " +
					host + ", port; " + port
			end
		rescue
			retried := True
			retry
		end

end
