/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.util.*;

// Options specified by the user
abstract public class MAS_Options implements OptionFlags {

//!!!It may be appropriate to move this to the descendant
//CommandLineOptions because the applet doesn't need it:
	// Host name of the server
	public String hostname() {
		return hostname_;
	}

//!!!It may be appropriate to move this to the descendant
//CommandLineOptions because the applet doesn't need it:
	// Port number to use for the socket connection
	public int port_number() {
		return port_number_;
	}

	// Should all selections be printed on startup?
	public boolean print_on_startup() {
		return print_on_startup_;
	}

	// Request server to compress the data?
	public boolean compression() {
		return compression_;
	}

	// All user-specified symbols (Vector of String) - null if none
	// specified
	Vector symbols() {
		return symbols_;
	}

	protected void set_print_on_startup(boolean v) {
		print_on_startup_ = v;
	}

	protected void set_compression(boolean v) {
		compression_ = v;
	}

// Implementation

	protected boolean print_on_startup_;
	protected boolean compression_;
	protected Vector symbols_;
	protected String hostname_ = null;
	protected int port_number_;
}
