/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_library;

import java.util.*;

// Start-up options specified by the user
abstract public class StartupOptions implements OptionFlags {

	// Should all selections be printed on startup?
	public boolean print_on_startup() {
		return print_on_startup;
	}

	// Request server to compress the data?
	public boolean compression() {
		return compression;
	}

	// Should debugging information be output?
	public boolean debug() {
		return debug;
	}

	// Is the auto-data-refresh feature to be enabled?
	public boolean auto_refresh() {
		return auto_refresh;
	}

	// All user-specified symbols (Vector of String) - null if none
	// specified
	public Vector symbols() {
		return symbols;
	}

	protected void set_print_on_startup(boolean v) {
		print_on_startup = v;
	}

	protected void set_compression(boolean v) {
		compression = v;
	}

	protected void set_debug(boolean v) {
		debug = v;
	}

	protected void set_auto_refresh(boolean v) {
		auto_refresh = v;
	}

// Implementation

	protected boolean print_on_startup;
	protected boolean compression;
	protected boolean debug;
	protected boolean auto_refresh;
	protected Vector symbols;
}
