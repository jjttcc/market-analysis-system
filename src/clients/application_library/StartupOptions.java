/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.util.*;

//!!!!Need parent class without argument parsing?  (And make this something
//like MAS_CommandLineOptions?)
// Options specified on the command line
public class MAS_Options implements OptionFlags {

	public MAS_Options(String[] args) {
		//Process args for the host, port.
		if (args.length > 1) {
			hostname_ = args[0];
			port_number_ = Integer.parseInt(args[1]);
			for (int i = 2; i < args.length; ++i) {
				if (args[i].equals(symbol_option)) {
					symbols_ = new Vector();
					for (i = i + 1; i < args.length; ++i) {
						if (args[i].charAt(0) == flag_character) {
							break;
						}
						symbols_.addElement(args[i]);
					}
				}
				if (i < args.length && args[i].equals(printall_option)) {
					set_print_on_startup(true);
				}
				if (i < args.length && args[i].equals(compression_option)) {
					set_compression(true);
				}
			}
		} else {
			usage();
			System.exit(1);
		}
	}

	// Host name of the server
	public String hostname() {
		return hostname_;
	}

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

//!!!Check if this is used (by removing and compiling):
	// Initial period type - null if not specified
	public String period_type() {
		return period_type_;
	}

	// All user-specified symbols (Vector of String) - null if none
	// specified
	Vector symbols() {
		return symbols_;
	}

//!!!Check if this is used (by removing and compiling):
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

// Implementation

	private void usage() {
		System.err.println("Usage: MA_Client hostname port_number [options]\n"+
		"Options:\n   "+ symbol_option +" symbol ..." +
		"    Include only the specified symbols in the selection list.\n" +
		"   " + printall_option +
		"           Print the chart for each symbol.\n" +
		"   " + compression_option +
		"               Request compressed data from server."
		);
	}

	private boolean print_on_startup_;
	private boolean compression_;
	private String period_type_;
	private Vector symbols_;
	private Vector indicators_;
	private String hostname_ = null;
	private int port_number_;
}
