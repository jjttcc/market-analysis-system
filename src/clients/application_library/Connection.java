/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;
import java.util.*;
import common.*;
import graph.*;
import support.*;

/** Provides an interface for connecting and communicating with the server */
public class Connection implements NetworkProtocol
{
	// args[0]: hostname, args[1]: port_number
	public Connection(String hostname, Integer port_number) {
		_hostname = hostname;
		_port_number = port_number;
		scanner = new DataInspector();
	}

	public String hostname() { return _hostname; }

	public Integer port_number() { return _port_number; }

	// Is this connection currently logged in to the server?
	public boolean logged_in() { return _logged_in; }

	// Log in to the server with the specified login request code.
	// Precondition: ! logged_in()
	// Postcondition: logged_in()
	public void login(int login_request_code) {
		_session_key = 0;
		String session_key_str = "";
		Configuration conf = Configuration.instance();

		connect();
		send_msg(login_request_code, conf.session_settings(), 0);
		try {
			session_key_str = receive_msg().toString();
			if (error_occurred()) {
				// Failure of login request is a fatal error.
				System.err.println(request_result);
				System.exit(-1);
			}
		}
		catch (Exception e) {
			System.err.println("Fatal error: attempt to login to server " +
				"failed: " + e);
			e.printStackTrace();
			System.exit(-1);
		}
		try {
			_session_key = Integer.valueOf(session_key_str).intValue();
		}
		catch (Exception e) {
			System.err.println("Fatal error: received invalid key from " +
				"server: " + session_key_str);
			System.exit(-1);
		}
		try {
			close_connection();
		}
		catch (Exception e) {
			System.err.println("Fatal error: close connection failed");
			System.exit(-1);
		}
		_logged_in = true;
System.out.println("session key is " + _session_key);
	}

	// Send a logout request to the server to end the current session.
	// Precondition:  logged_in()
	public void logout(int logout_request_code) {
		connect();
		send_msg(logout_request_code, "", _session_key);
		try {
			close_connection();
		}
		catch (Exception e) {
			System.err.println("Error: close connection failed");
		}
	}

	// Send a request to the server.
	// Precondition:  logged_in()
	// Postcondition: `result' gives the data resulting from this request.
	public void send_request(int request_code, String request)
			throws IOException {
		connect();
		send_msg(request_code, request, _session_key);
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
		final int Max_input_count = 1000000;
		char c;
		int i;

		in = new_reader_from_socket();
		scanner.setReader(in);
		scanner.getInt();
		last_rec_msgID = scanner.lastInt();
		if (! valid_server_response(last_rec_msgID)) {
			if (last_rec_msgID == Error) {
				request_result =
					new StringBuffer("Fatal request protocol error\n");
			} else {
				System.err.println("Fatal error: received invalid " +
					"message ID from server: " + last_rec_msgID);
				System.exit(-1);
			}
		} else {
			request_result = new StringBuffer();
		}
		i = 0;
		do {
			c = (char) in.read();
			if (c == Eom_char) break;
			request_result.append(c);
			++i;
			if (i > Max_input_count) {
				message_too_large(Max_input_count);
			}
		} while (true);

		if (last_rec_msgID == Error) {
			System.err.println(request_result);
			// This error means there is a problem with the protocol of the
			// last request passed to the server.  Since this is a coding
			// error (probably in the client), it is treated as fatal.
			System.exit(-1);
		}
//System.out.println("'"  + request_result.toString() + "'");
		return request_result;
	}

	// Send the `msgID', the session key, and `msg' - with field delimiters.
	void send_msg(int msgID, String msg, int session_key) {
		out.print(msgID);
		out.print(Input_field_separator + session_key);
		out.print(Input_field_separator + msg);
		out.print(Eom);
		out.flush();
	}

	// Precondition: out != null && socket != null
	void close_connection() throws IOException {
		out.close(); socket.close();
		if (in != null) {
			in.close();
		}
	}

	private void connect() {
		try {
			//It appears that the only way to connect a client socket is
			//to create a new one!
			socket = new Socket(_hostname, _port_number.intValue());
			out = new PrintWriter(socket.getOutputStream(), true);
			in = null;
		}
		catch (UnknownHostException e) {
			System.err.println("Don't know about host: ");
			System.err.println(_hostname);
			System.exit(1);
		}
		catch (IOException e) {
			System.err.println("Couldn't get I/O for the connection to: " +
								_hostname);
			System.exit(1);
		}
	}

	boolean error_occurred() {
		return last_rec_msgID != OK;
	}

	// A new Reader object created with socket's input stream
	protected Reader new_reader_from_socket() {
System.out.println("\nnot decompressing");
		Reader result = null;
		try {
			result = new BufferedReader(new InputStreamReader(
			new BufferedInputStream(socket.getInputStream())));
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
		return value == OK || value == Error || value == Invalid_symbol;
	}

	protected int _session_key;
	protected boolean _logged_in = false;
	protected String _hostname;
	protected Integer _port_number;
	protected Socket socket;			// socket connection to server
	protected PrintWriter out;			// output to server via socket
	protected Reader in;				// input from server via socket
	protected DataInspector scanner;	// for scanning server messages
	protected int last_rec_msgID;		// last message ID received from server
	protected StringBuffer request_result;	// result of last data request
	static int Eom_char = Eom.charAt(0);
}
