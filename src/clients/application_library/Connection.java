/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package application_library;

import java.io.*;
import java.net.*;
import java.util.*;
import common.*;
import support.*;

/** Interface for connecting and communicating with the server */
abstract public class Connection {

	// Precondition: io_conn != null
	public Connection(IO_Connection io_conn) {
//		assert io_conn != null;

		io_connection = io_conn;
		scanner = new DataInspector();
	}

	// A new connection object
	abstract public Connection new_object() throws IOException;

	// Session state data received from the server when logging in.
	public SessionState session_state() {
		return _session_state;
	}

	// Is this connection currently logged in to the server?
	public boolean logged_in() { return _logged_in; }

	// Log in to the server with the specified login request code.
	// Precondition: ! logged_in()
	// Postcondition: logged_in() && session_state() != null
	public void login() throws IOException {
		String s = "";
		Configuration conf = Configuration.instance();

		connect();
		send_msg(Login_request_code, conf.session_settings(), 0);
		try {
			s = receive_msg().toString();
			if (error_occurred()) {
				// Failure of login request is a fatal error.
				throw new IOException (request_result.toString());
			}
			_session_state = new_session_state(s);
		} catch (IOException e) {
			throw new IOException("Attempt to login to server " +
				"failed: " + e);
		}
		try {
			close_connection();
		} catch (Exception e) {
			throw new IOException("Close connection failed");
		}
		_logged_in = true;
	}

	// Send a logout request to the server to end the current session.
	// Precondition:  logged_in()
	public void logout() throws IOException {
		connect();
		send_msg(Logout_request_code, "", _session_state.session_key());
		try {
			close_connection();
		} catch (Exception e) {
			throw new IOException("Error: close connection failed" + e);
		}
	}

	// Send a request to the server.
	// Precondition:  logged_in()
	// Postcondition: `result()' gives the data resulting from this request.
	public void send_request(int request_code, String request)
			throws IOException {
		connect();
		send_msg(request_code, request, _session_state.session_key());
		receive_msg();
		close_connection();
	}

	// The data resulting from the last call to `send_request'
	public StringBuffer result() {
		return request_result;
	}

	// Last message ID received back from the server
	public int last_received_message_ID() {
		return last_rec_msgID;
	}

// Implementation

	// Receive the current pending message from the server.
	protected StringBuffer receive_msg() throws IOException {
		char c;
		int i;

		in = new_reader();
		scanner.setReader(in);
		scanner.getInt();
		last_rec_msgID = scanner.lastInt();
		if (! valid_server_response(last_rec_msgID)) {
			System.err.println("Fatal error: received invalid " +
				"message ID from server: " + last_rec_msgID);
			Configuration.terminate(-1);
		} else {
			request_result = new StringBuffer();
		}
		i = 0;
		do {
			c = (char) in.read();
			if (c == Eom_char) break;
			request_result.append(c);
			++i;
		} while (true);

		if (last_rec_msgID == Error_code) {
			System.err.println(request_result);
			// This error means there is a problem with the protocol of the
			// last request passed to the server.  Since this is a coding
			// error (probably in the client), it is treated as fatal.
			Configuration.terminate(-1);
		}
//System.out.println("'"  + request_result.toString() + "'");
		return request_result;
	}

	// Send the `msgID', the session key, and `msg' - with field delimiters.
	void send_msg(int msgID, String msg, int session_key) {
		out.print(msgID);
		out.print(Message_field_separator_string + session_key);
		out.print(Message_field_separator_string + msg);
		out.print(Eom_string);
		out.flush();
	}

	// Precondition: out != null && io_connection != null
	void close_connection() throws IOException {
		out.close(); io_connection.close();
		if (in != null) {
			in.close();
		}
	}

	private void connect() throws IOException {
		io_connection.open();
		out = new PrintWriter(io_connection.output_stream(), true);
		in = null;
	}

	public boolean error_occurred() {
		return last_rec_msgID != OK_code;
	}

	// A new Reader object created with io_connection's input stream
	protected Reader new_reader() throws IOException {
//System.out.println("\nnot decompressing");
		Reader result = null;
		try {
			result = new BufferedReader(new InputStreamReader(
				new BufferedInputStream(io_connection.input_stream())));
		} catch (IOException e) {
			System.err.println("Failed to read from server (" + e + ")");
			Configuration.terminate(1);
			throw e;
		}
		return result;
	}

	// Handle message- (from server) too-large situation.
	void message_too_large(int size) {
		System.err.println("Message from server exceeded maximum " +
			"buffer size of " + size + " - aborting");
		Configuration.terminate(-1);
	}

	// Is `value' a valid server response?
	boolean valid_server_response(int value) {
		return value == OK_code || value == Error_code ||
			value == Warning_code || valid_application_server_response(value);
	}

	// Is `value' a valid server response for this application?
	// (Redefine this method in descendants, if needed.)
	boolean valid_application_server_response(int value) {
		return true;
	}

	// A new SessionState object of the appropriate descendant class
	protected abstract SessionState new_session_state(String response)
		throws IOException;

// Implementation - Hook routines

	protected abstract int login_request_code();
	protected abstract int logout_request_code();
	protected abstract int error_code();
	protected abstract int ok_code();
	protected abstract int warning_code();
	protected abstract String eom_string();
	protected abstract String msg_fld_sep();

	protected SessionState _session_state;
	protected boolean _logged_in = false;
	protected String _hostname;
	protected Integer _port_number;
	protected IO_Connection io_connection;	// IO connection to server
	protected PrintWriter out;			// output to server via io_connection
	protected Reader in;				// input from server via io_connection
	protected DataInspector scanner;	// for scanning server messages
	protected int last_rec_msgID;		// last message ID received from server
	protected StringBuffer request_result;	// result of last data request
	protected int Login_request_code = login_request_code();
	protected int Logout_request_code = logout_request_code();
	protected int Error_code = error_code();
	protected int OK_code = ok_code();
	protected int Warning_code = warning_code();
	protected String Eom_string = eom_string();
	protected String Message_field_separator_string = msg_fld_sep();
	protected int Eom_char = Eom_string.charAt(0);
}
