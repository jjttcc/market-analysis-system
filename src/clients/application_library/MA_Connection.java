/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import support.*;

/** Connection specialized for MAS */
public class MA_Connection extends Connection {

	// Precondition: io_conn != null
	public MA_Connection(IO_Connection io_conn) {
		super(io_conn);
//		assert io_conn != null;
	}

	public Connection new_object() throws IOException {
		return new MA_Connection(io_connection.new_object());
	}

// Implementation

	protected boolean valid_application_server_response(int value) {
		return value == Invalid_symbol;
	}

	protected SessionState new_session_state(String response)
			throws IOException {
		return new MA_SessionState(response);
	}
}
