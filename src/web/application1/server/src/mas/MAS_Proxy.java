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

	// Precondition: conn != null
	public MAS_Proxy(IO_Connection conn) {
		assert conn != null;
		connection = conn;
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
		connection.open();
		PrintWriter writer = null;
		try {
			writer = new PrintWriter(connection.output_stream(), true);
			writer.print(msg);
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
	private boolean error_ = false;
	private String last_error_ = "";
}
