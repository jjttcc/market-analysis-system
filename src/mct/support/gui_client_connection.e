note
	description: "Client socket connection to the server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class GUI_CLIENT_CONNECTION inherit

	CLIENT_CONNECTION
		export
			{NONE} connected
		redefine
			process_response
		end

	GUI_COMMUNICATION_PROTOCOL
		export
			{NONE} all
		end

creation

	make_tested

feature -- Access

	indicators: LIST [STRING]
			-- Indicator list received from the server as the result of
			-- an indicator request

feature -- Status report

	logged_in: BOOLEAN
			-- Is Current logged in to the server?

feature -- Basic operations

	ping_server
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

	login
			-- Log in to the server.
		require
			not_logged_in: not logged_in
		do
			send_one_time_request (Login_request_msg, True)
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

	logout
			-- Log out from the server.
		require
			logged_in: logged_in
		do
			send_one_time_request (Logout_request_msg, False)
			logged_in := False
		ensure
			not_connected: not connected
			not_logged_in: not logged_in
		end

	request_indicators
			-- Request list of all available indicators from the server.
		require
			logged_in: logged_in
		local
			su: expanded STRING_UTILITIES
		do
			send_one_time_request (All_indicators_request_msg, True)
			if last_communication_succeeded then
				su.set_target (server_response)
				indicators := su.tokens (message_record_separator)
			end
		ensure
			not_connected: not connected
			indicators_set_on_success:
				last_communication_succeeded implies indicators /= Void
			still_logged_in: logged_in
		end

feature {NONE} -- Implementation

	process_response (s: STRING)
			-- Process server response `s' - set `server_response' and
			-- `last_communication_succeeded' accordingly.
		local
			su: expanded STRING_UTILITIES
			l: LIST [STRING]
		do
			su.set_target (s)
			l := su.tokens (message_component_separator)
			process_error (l, s)
			if last_communication_succeeded then
				server_response := l @ 2
			end
		end

	process_error (l: LIST [STRING]; msg: STRING)
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

	timeout_seconds: INTEGER = 10
			-- Number of seconds client will wait for server to respond
			-- before reporting a "timed-out" message

	login_request_msg: STRING
			-- Login request to the server
		once
			Result := Login_request.out + message_component_separator + "0" +
				message_component_separator + eom
		end

	logout_request_msg: STRING
			-- Logout request to the server
		do
			Result := Logout_request.out + message_component_separator +
				session_key.out + message_component_separator + eom
		end

	all_indicators_request_msg: STRING
			-- "all-indicators" request to the server
		do
			Result := All_indicators_request.out + message_component_separator +
				session_key.out + message_component_separator + eom
		end

	end_of_message (c: CHARACTER): BOOLEAN
		do
			Result := c = eom @ 1
		end

invariant

	server_response_exists_if_succeeded:
		last_communication_succeeded implies server_response /= Void
	error_report_exists_on_failure:
		not last_communication_succeeded implies error_report /= Void
	positive_session_key_if_logged_in: logged_in implies session_key > 0

end
