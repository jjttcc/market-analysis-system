/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import common.*;
import java.io.*;
import java.util.*;

class MA_SessionState extends SessionState implements NetworkProtocol {
	// `response_string' is the string sent by the server in response to
	// a login request.
	MA_SessionState(String response_string) throws IOException {
		super(response_string);
	}

	// Is there an open field in the data recevied from the server?
	public boolean open_field() {
		return _open_field;
	}

	// Specify whether there is an open field in the data recevied from
	// the server.
	// Postcondition: open_field() == value
	public void set_open_field(boolean value) {
		_open_field = value;
	}

	protected void process_remaining_tokens(StringTokenizer t) {
System.out.println("prt called");
		String s;
		while (t.hasMoreTokens()) {
			s = t.nextToken();
			if (s.equals(No_open_session_state)) {
				_open_field = false;
			}
		}
	}

	protected String message_field_separator() {
System.out.println("mfs called");
		return Message_field_separator;
	}

	private boolean _open_field = true;
}
