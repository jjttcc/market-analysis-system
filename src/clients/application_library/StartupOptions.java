/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_library;

import java.util.*;
import java_library.support.*;

/**
* Start-up options specified by the user
**/
abstract public class StartupOptions implements OptionFlags,
	AssertionConstants {

// Access

	/**
	* Should all selections be printed on startup?
	**/
	public boolean print_on_startup() {
		return print_on_startup;
	}

	/**
	* Request server to compress the data?
	**/
	public boolean compression() {
		return compression;
	}

	/**
	* Should debugging information be output?
	**/
	public boolean debug() {
		return debug;
	}

	/**
	* Is the polling-based auto-data-refresh feature to be enabled?
	**/
	public boolean auto_refresh() {
		return auto_refresh;
	}

	/**
	* Delay in seconds to employ for polling-based auto-data-refresh
	**/
	public int auto_refresh_delay() {
		return auto_refresh_delay;
	}

	/**
	* All user-specified symbols (Vector of String) - null if none
	* specified
	**/
	public Vector symbols() {
		return symbols;
	}

// Implementation

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

	protected void parse_auto_refresh_settings(String s) {
		assert s != null: PRECONDITION;
		refresh_settings_parse_error = false;
		String[] components = s.split(AUTO_REFRESH_SEPARATOR);
		String errormsg = "Invalid setting for auto-refresh delay";
		if (components.length > 1) {
			try {
				auto_refresh_delay = new Integer(components[1]).intValue();
			} catch (Exception e) {
				refresh_settings_parse_error = true;
			}
		} else {
			refresh_settings_parse_error = true;
		}
		if (refresh_settings_parse_error) {
			System.err.println(errormsg);
		} else {
			set_auto_refresh(true);
		}
	}

// Implementation - Attributes

	protected boolean print_on_startup;
	protected boolean compression;
	protected boolean debug;
	protected boolean auto_refresh;
	protected int auto_refresh_delay;
	protected Vector symbols;
	protected boolean refresh_settings_parse_error;
	private static String AUTO_REFRESH_SEPARATOR = ":";
}
