/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

package mas;

import java.io.*;
import java_library.support.*;
import support.IO_Connection;
import support.Utilities;

// Abstraction that forwards client requests to the MAS server
public class MAS_Proxy implements AssertionConstants {

	// Precondition: conn != null
	public MAS_Proxy(IO_Connection conn) {
		assert conn != null: PRECONDITION;
		connection = conn;
	}

// Access

	// The server's response to the last forwarded request
	public String response() {
		return response_;
	}

	// The last client request forwarded to the server
	public String last_client_request() {
		return client_request;
	}

	// Did an error occur during the last operation?
	public String last_error() {
		return last_error_;
	}

// Status report

	// Did an error occur during the last operation?
	public boolean error_occurred() {
		return error_;
	}

// Basic operations

	// Forward the input string in 'r' to the server and obtain the response.
	// Precondition: r != null
	// Postcondition: response() != null
	public void forward(Reader r) throws IOException {
		assert r != null: PRECONDITION;
		error_ = false;
		response_ = "";
		client_request = Utilities.input_string(r);
		connection.open();
		PrintWriter writer = null;
		try {
			writer = new PrintWriter(connection.output_stream(), true);
			writer.print(client_request);
			writer.flush();
		} catch (IOException e) {
			error_ = true;
			last_error_ = e.toString();
		}
		if (! error_) {
			receive_response();
		}
		if (writer != null) writer.close();
		connection.close();
		assert response() != null: POSTCONDITION;
	}

// Implementation

	// Receive the response from the server.
	// Precondition: ! error_occurred()
	private void receive_response() {
		assert ! error_occurred(): PRECONDITION;
		response_ = null;
		Reader reader;
		try {
			reader = new BufferedReader(new InputStreamReader(
				new BufferedInputStream(connection.input_stream())));
			response_ = Utilities.input_string(reader);
			if (response_ == null || response_.length() == 0) {
				response_ = "(Server returned empty message.)";
			}
		} catch (Exception e) {
			response_ = "ERROR: " + e.toString();
			error_ = true;
			last_error_ = new String (response_);
		}
	}

	private IO_Connection connection;
	private String response_;
	private String client_request;
	private boolean error_ = false;
	private String last_error_ = "";
}
