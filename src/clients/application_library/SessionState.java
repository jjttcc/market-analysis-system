/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import common.*;
import java.io.*;
import java.util.*;

public abstract class SessionState {
	// `response_string' is the string sent by the server in response to
	// a login request.
	public SessionState(String response_string) throws IOException {
		StringTokenizer t = new StringTokenizer(response_string,
			message_field_separator());
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
		process_remaining_tokens(t);
	}

	// The "session key" - used for requests to the server
	public int session_key() {
		return _session_key;
	}

	// Process the remaining tokens in `t', if any, to obtain session
	// state information sent by the server.
	protected void process_remaining_tokens(StringTokenizer t) {
		// null routine - redefined if needed.
	}

	protected abstract String message_field_separator();

	private int _session_key;
}
