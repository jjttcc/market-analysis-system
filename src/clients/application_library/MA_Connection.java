/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import support.*;
import common.*;

/** Connection specialized for MAS */
public class MA_Connection extends Connection implements NetworkProtocol {

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

// Hook routine implementations

	protected int login_request_code() {
		return Login_request;
	}

	protected int logout_request_code() {
		return Logout_request;
	}

	protected int error_code() {
		return Error;
	}

	protected int ok_code() {
		return OK;
	}

	protected int warning_code() {
		return Warning;
	}

	protected String eom_string() {
		return Eom;
	}

	protected String msg_fld_sep() {
		return Message_field_separator;
	}
}
