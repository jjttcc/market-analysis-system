/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.util.*;

// Options specified on the command line
public class MAS_Options {

	public MAS_Options() {
	}

	// Should all selections be printed on startup?
	public boolean print_on_startup() {
		return print_on_startup_;
	}

	// Request server to compress the data?
	public boolean compression() {
		return compression_;
	}

	// Initial period type - null if not specified
	public String period_type() {
		return period_type_;
	}

	// Initial indicators - null if not specified
	public Vector indicators() {
		return indicators_;
	}

	protected void set_print_on_startup(boolean v) {
		print_on_startup_ = v;
	}

	protected void set_compression(boolean v) {
		compression_ = v;
	}

	private boolean print_on_startup_;
	private boolean compression_;
	private String period_type_;
	private Vector indicators_;
}
