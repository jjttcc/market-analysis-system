/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

import java.applet.*;
import java.awt.*;
import java.net.*;
import java.io.*;
import java.util.*;
import support.*;

// Test applet that communicates with the servlet
public class MAS_Applet extends Applet {
	public void paint(Graphics g) {
		if (display_message != null) {
			g.drawString(display_message, 5, 50);
		}
	}

	public void init() {
		LinkedList msglst;
		ListIterator msgs;
System.out.println("Test of sending to stdout.");
		try {
			initialize();
			msglst = new LinkedList();
			msglst.add("I am using regular IO!");
			msglst.add("This is the SECOND message!");
			msglst.add("This is the THIRD message!");
			if (use_socket) {
				msglst.add("(Using socket) hostname: " + host_name);
			} else {
				msglst.add("(Using URL) hostname: " + host_name);
			}
			for (msgs = msglst.listIterator(); msgs.hasNext(); ) {
				connection.open();
				send_msg((String) msgs.next());
				display("srvr: " + server_response());
				connection.close();
			}
		} catch (Exception e) {
			log(e.toString());
		}
	}

	public void start() {
		showStatus("Is this displayed or not??????");
	}

// Implementation

	// Send 'msg' to the servlet.
	private void send_msg(String msg) {
		PrintWriter writer;
		try {
			writer = new PrintWriter(connection.output_stream(), true);
			writer.print(msg + eom);
			writer.flush();
			writer.close();
		} catch (IOException e) {
		  log(e.toString());
		}
	}

	// Response from the server
	private String server_response() {
		String result = null;
		Reader reader;

		try {
			reader = new BufferedReader(new InputStreamReader(
				new BufferedInputStream(connection.input_stream())));
			result = input_string(reader);
			if (result == null || result.length() == 0) {
				result = "(Server returned empty message.)";
			}
		} catch (Exception e) {
			result = "ERROR: " + e.toString();
		}
		return result;
	}

	String input_string(Reader r) throws IOException {
		char[] buffer = new char[16384];
		int c = 0, i = 0;
		do {
			c = r.read();
			buffer[i] = (char) c;
			++i;
		} while (c != -1);
		return new String(buffer, 0, i - 1);
	}

// Implementation - initialization

	// Postcondition: host_name != null && server_address != null &&
	//    port > 0 && connection != null
	private void initialize() throws Exception {
		URL host_url = getCodeBase();
		host_name = host_url.getHost();
		port = host_url.getPort();
		if (port == -1)
		{
			port = 80;
		}
		server_address = "http://" + host_name + ":" + port + servlet_path;
		if (use_socket) {
			create_socket_connection();
		} else {
			create_url_connection();
		}
		assert host_name != null && server_address != null && port > 0 &&
			connection != null;
	}

// Implementation - utilities

	// Connection to the server for binary input and ouput with caching off
	// Precondition: server_address != null
	private void create_url_connection() throws Exception {
		connection = new IO_URL_Connection(server_address);
		assert connection != null;
	}

	// Socket connection to the server
	// Precondition: host_name != null
	private void create_socket_connection() throws Exception {
		connection = new IO_SocketConnection(host_name, 2003);
		assert connection != null;
	}

	private void display(String msg) {
		display_message = msg;
		System.out.println(msg + "\n");
		showStatus(msg);
	}

	private void log(String msg) {
		showStatus(msg);
		System.out.println(msg + "\n");
	}

// Implementation - attributes

	private String host_name = "";
	private int port = -1;
	private String display_message;
	private IO_Connection connection;

	private String servlet_path = "/mas/mas";
	private String server_address = null;
	private boolean use_socket = false;
	private String eom = "";
}
