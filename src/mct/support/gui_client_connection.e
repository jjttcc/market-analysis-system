indexing
	description: "Client socket connection to the server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined"

class GUI_CLIENT_CONNECTION inherit

	CLIENT_CONNECTION
		export
			{NONE} connected
		end

	GUI_NETWORK_PROTOCOL

creation

	make

feature -- Access

	indicators: LIST [STRING]
			-- Indicator list received from the server as the result of
			-- an indicator request

feature -- Status report

	logged_in: BOOLEAN
			-- Is Current logged in to the server?

feature -- Basic operations

	ping_server is
			-- "Ping" the server by attempting to log in and log back out.
		require
			not_logged_in: not logged_in
		do
			login
			if logged_in then
				logout
			end
		ensure
			not_logged_in: not logged_in
		end

	login is
			-- Log in to the server.
		require
			not_logged_in: not logged_in
		do
			send_request (Login_request_msg, True)
			if last_communication_succeeded then
				if server_response.is_integer then
					session_key := server_response.to_integer
				else
					last_communication_succeeded := False
					error_report := "Invalid login response received %
						%from the server: " + server_response
				end
			end
			logged_in := last_communication_succeeded
		ensure
			not_connected: not connected
			logged_in_on_success:
				last_communication_succeeded = logged_in
		end

	logout is
			-- Log out from the server.
		require
			logged_in: logged_in
		do
			send_request (Logout_request_msg, False)
			logged_in := False
		ensure
			not_connected: not connected
			not_logged_in: not logged_in
		end

	request_indicators is
			-- Request list of all available indicators from the server.
		require
			logged_in: logged_in
		local
			su: expanded STRING_UTILITIES
		do
			send_request (All_indicators_request_msg, True)
			if last_communication_succeeded then
				su.set_target (server_response)
				indicators := su.tokens (Message_record_separator)
			end
		ensure
			not_connected: not connected
			indicators_set_on_success:
				last_communication_succeeded implies indicators /= Void
			still_logged_in: logged_in
		end

feature {NONE} -- Implementation

	process_response (s: STRING) is
			-- Process server response `s' - set `server_response' and
			-- `last_communication_succeeded' accordingly.
		local
			su: expanded STRING_UTILITIES
			l: LIST [STRING]
		do
			su.set_target (s)
			l := su.tokens (Message_field_separator)
			process_error (l, s)
			if last_communication_succeeded then
				server_response := l @ 2
			end
		end

	process_error (l: LIST [STRING]; msg: STRING) is
			-- Process any errors in the server response, `l'.  If there
			-- are errors, update `last_communication_succeeded' and
			-- error_report accordingly.  (`msg' is the entire message
			-- string sent by the server.)
		require
			args_exist: l /= Void and msg /= Void
		do
			last_communication_succeeded := False
			if l.is_empty then
				error_report := "Server result was empty."
			elseif not l.i_th (1).is_integer then
				error_report := "Server result was invalid: " + msg + "."
			elseif l.i_th (1).to_integer /= OK then
				error_report := "Server returned error status"
				if l.count > 1 then
					error_report.append (": " + l @ 2)
				end
			else
				last_communication_succeeded := True
			end
		end

feature {NONE} -- Implementation - attributes

	session_key: INTEGER

feature {NONE} -- Implementation - constants

	Timeout_seconds: INTEGER is 10
			-- Number of seconds client will wait for server to respond
			-- before reporting a "timed-out" message

	Login_request_msg: STRING is
			-- Login request to the server
		once
			Result := Login_request.out + Message_field_separator + "0" +
				Message_field_separator + eom
		end

	Logout_request_msg: STRING is
			-- Logout request to the server
		do
			Result := Logout_request.out + Message_field_separator +
				session_key.out + Message_field_separator + eom
		end

	All_indicators_request_msg: STRING is
			-- "all-indicators" request to the server
		do
			Result := All_indicators_request.out + Message_field_separator +
				session_key.out + Message_field_separator + eom
		end

invariant

	server_response_exists_if_succeeded:
		last_communication_succeeded implies server_response /= Void
	error_report_exists_on_failure:
		not last_communication_succeeded implies error_report /= Void
	positive_session_key_if_logged_in: logged_in implies session_key > 0

end
