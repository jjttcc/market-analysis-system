/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package applet;

import application_library.*;

// User-specified options for the applet version
public class AppletOptions extends StartupOptions {

	public AppletOptions() {
		set_print_on_startup(false);
		set_compression(false);
	}
}
