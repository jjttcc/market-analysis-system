/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import common.*;
import java.io.*;
import java.util.*;

class SessionState implements NetworkProtocol {
	// `response_string' is the string sent by the server in response to
	// a login request.
	SessionState(String response_string) throws IOException {
		StringTokenizer t = new StringTokenizer(response_string,
			Output_field_separator);
		String s = null;
		if (! t.hasMoreTokens()) {
			throw new IOException("Received empty key from server.");
		}
		// Obtain the session key.
		try {
			s = t.nextToken();
			_session_key = Integer.valueOf(s).intValue();
		}
		catch (Exception e) {
			throw new IOException("Received invalid key from " +
				"server: " + s + " - " + e);
		}
		// Obtain any session state information sent by the server.
		while (t.hasMoreTokens()) {
			s = t.nextToken();
			if (s.equals(No_open_session_state)) {
				_open_field = false;
			}
		}
	}

	// The "session key" - used for requests to the server
	public int session_key() {
		return _session_key;
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

	private int _session_key;

	private boolean _open_field = true;
}
