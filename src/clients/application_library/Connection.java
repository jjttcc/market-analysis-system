/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import java.net.*;
import java.util.*;
import common.*;
import support.*;
import mas_gui.*;

/** Interface for connecting and communicating with the server */
public class Connection implements NetworkProtocol, Constants {

	// Precondition: io_conn != null
	public Connection(IO_Connection io_conn) {
		assert io_conn != null;

		io_connection = io_conn;
		scanner = new DataInspector();
	}

	// A new connection object
	public Connection new_object() throws IOException {
		return new Connection(io_connection.new_object());
	}

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
System.out.println("Connection.login A");
		String s = "";
		Configuration conf = Configuration.instance();
System.out.println("Connection.login B");

		connect();
System.out.println("Connection.login C");
		send_msg(Login_request, conf.session_settings(), 0);
		try {
System.out.println("Connection.login D");
			s = receive_msg().toString();
System.out.println("Connection.login E");
			if (error_occurred()) {
System.out.println("Connection.login F");
				// Failure of login request is a fatal error.
				throw new IOException (request_result.toString());
			}
			_session_state = new SessionState(s);
System.out.println("Connection.login G");
		} catch (Exception e) {
System.out.println("Connection.login H");
			throw new IOException("Attempt to login to server " +
				"failed: " + e);
		}
		try {
System.out.println("Connection.login I");
			close_connection();
System.out.println("Connection.login J");
		} catch (Exception e) {
System.out.println("Connection.login K");
			throw new IOException("Close connection failed");
		}
		_logged_in = true;
System.out.println("Connection.login L");
	}

	// Send a logout request to the server to end the current session.
	// Precondition:  logged_in()
	public void logout() throws IOException {
		connect();
		send_msg(Logout_request, "", _session_state.session_key());
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

System.out.println("Connection.receive_msg A");
		in = new_reader();
System.out.println("Connection.receive_msg B");
		scanner.setReader(in);
System.out.println("Connection.receive_msg C");
		scanner.getInt();
System.out.println("Connection.receive_msg D");
		last_rec_msgID = scanner.lastInt();
System.out.println("Connection.receive_msg E");
		if (! valid_server_response(last_rec_msgID)) {
			System.err.println("Fatal error: received invalid " +
				"message ID from server: " + last_rec_msgID);
System.out.println("Connection.receive_msg F");
			System.exit(-1);
		} else {
System.out.println("Connection.receive_msg G");
			request_result = new StringBuffer();
		}
		i = 0;
System.out.println("Connection.receive_msg H");
		do {
			c = (char) in.read();
			if (c == Eom_char) break;
			request_result.append(c);
			++i;
		} while (true);

System.out.println("Connection.receive_msg I");
		if (last_rec_msgID == Error) {
System.out.println("Connection.receive_msg J");
			System.err.println(request_result);
			// This error means there is a problem with the protocol of the
			// last request passed to the server.  Since this is a coding
			// error (probably in the client), it is treated as fatal.
			System.exit(-1);
		}
System.out.println("Connection.receive_msg K");
//System.out.println("'"  + request_result.toString() + "'");
		return request_result;
	}

	// Send the `msgID', the session key, and `msg' - with field delimiters.
	void send_msg(int msgID, String msg, int session_key) {
System.out.println("Connection.send_msg A");
		out.print(msgID);
System.out.println("Connection.send_msg B");
		out.print(Input_field_separator + session_key);
System.out.println("Connection.send_msg C");
		out.print(Input_field_separator + msg);
System.out.println("Connection.send_msg D");
		out.print(Eom);
System.out.println("Connection.send_msg E");
		out.flush();
System.out.println("Connection.send_msg F");
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

	boolean error_occurred() {
		return last_rec_msgID != OK;
	}

	// A new Reader object created with io_connection's input stream
	protected Reader new_reader() {
//System.out.println("\nnot decompressing");
		Reader result = null;
		try {
			result = new BufferedReader(new InputStreamReader(
				new BufferedInputStream(io_connection.input_stream())));
		} catch (Exception e) {
			System.err.println("Failed to read from server (" + e + ")");
			System.exit(1);
		}
		return result;
	}

	// Handle message- (from server) too-large situation.
	void message_too_large(int size) {
		System.err.println("Message from server exceeded maximum " +
			"buffer size of " + size + " - aborting");
		System.exit(-1);
	}

	// Is `value' a valid server response?
	boolean valid_server_response(int value) {
		return value == OK || value == Error || value == Invalid_symbol ||
			value == Warning;
	}

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
	static int Eom_char = Eom.charAt(0);
}
