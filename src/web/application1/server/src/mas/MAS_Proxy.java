/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

package mas;

import java.io.*;
import support.IO_Connection;
import support.Utilities;

// Abstraction that forwards client requests to the MAS server
public class MAS_Proxy {

//!!!Temporary debugging stuff:
private void log(String msg) {
	try {
		logfile.write(msg + "\n");
		logfile.flush();
	} catch (Exception e){}
}
FileWriter logfile;

	// Precondition: conn != null
	public MAS_Proxy(IO_Connection conn) {
try {
logfile = new FileWriter(new File("/tmp/proxylogfile"));
} catch(Exception e) {}
log("MAS_Proxy() called");
		assert conn != null;
		connection = conn;
log("MAS_Proxy() returning");
	}

// Access

	public String response() {
		return response_;
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
		assert r != null: "Precondition";
		error_ = false;
		String msg = Utilities.input_string(r);
log("'forward' opening a connection");
		connection.open();
log("connection opened");
		PrintWriter writer = null;
		try {
log("forwarding '" + msg + "'");
			writer = new PrintWriter(connection.output_stream(), true);
			writer.print(msg);
			writer.flush();
log("forward completed without an exception");
		} catch (IOException e) {
log("forward failed with an exception: "  + e.toString());
			error_ = true;
			last_error_ = e.toString();
		}
		if (! error_) {
			receive_response();
		}
		if (writer != null) writer.close();
		connection.close();
		assert response() != null: "Postcondition";
	}

// Implementation

	// Response from the server
	// Precondition: ! error_occurred()
	private void receive_response() {
		assert ! error_occurred(): "Precondition";
		response_ = null;
		Reader reader;
		try {
log("receiving response");
			reader = new BufferedReader(new InputStreamReader(
				new BufferedInputStream(connection.input_stream())));
			response_ = Utilities.input_string(reader);
log("received response: '" + response_ + "'");
			if (response_ == null || response_.length() == 0) {
log("response was null or empty");
				response_ = "(Server returned empty message.)";
			}
log("response received without an exception");
		} catch (Exception e) {
log("receive failed with an exception: '" + e.toString() + "'");
			response_ = "ERROR: " + e.toString();
			error_ = true;
			last_error_ = new String (response_);
		}
	}

	private IO_Connection connection;
	private String response_;
	private boolean error_ = false;
	private String last_error_ = "";
}
