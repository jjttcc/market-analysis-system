package pct.application;

import mas_gui.Connection;

// Utilities for communicating with the MAS server over a socket connection
class MAS_ConnectionUtilities extends Connection {
	public MAS_ConnectionUtilities(String hostname, Integer port_number) {
		super(hostname, port_number);
	}

	// Is the server alive and responding to requests?
	public boolean server_is_alive() {
		boolean result = true;
		// Looks like Connection needs to be changed to throw an exception
		// if the "login" fails instead of exiting (which does not conform
		// to what this feature needs).
		try {
			login();
			logout();
		} catch (Exception e) {
			result = false;
		}
		return result;
	}
}
