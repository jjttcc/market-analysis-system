/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_library;

import java.util.*;
import support.*;

// Options specified on the command line
public class CommandLineOptions extends StartupOptions {

	public CommandLineOptions(String[] args) {
		//Process args for the host, port.
		if (args.length > 1) {
			if (args[0].equals(version_option)) {
				print_version();
			}
			hostname = args[0];
			port_number = Integer.parseInt(args[1]);
			for (int i = 2; i < args.length; ++i) {
				if (args[i].equals(symbol_option)) {
					symbols = new Vector();
					for (i = i + 1; i < args.length; ++i) {
						if (args[i].charAt(0) == flag_character) {
							break;
						}
						symbols.addElement(args[i]);
					}
				}
				if (i < args.length && args[i].equals(version_option)) {
					print_version();
				}
				if (i < args.length && args[i].equals(printall_option)) {
					set_print_on_startup(true);
				}
				if (i < args.length && args[i].equals(compression_option)) {
					set_compression(true);
				}
				if (i < args.length && args[i].equals(debug_option)) {
					set_debug(true);
				}
				if (i < args.length && args[i].regionMatches(0,
						auto_refresh_option, 0, auto_refresh_option.length())) {
//				if (i < args.length && args[i].equals(auto_refresh_option)) {
					if (args[i].length() == auto_refresh_option.length()) {
						set_auto_refresh(true);
					} else {
						parse_auto_refresh_settings(args[i]);
						if (refresh_settings_parse_error) {
							usage();
							Configuration.terminate(1);
						}
					}
				}
			}
		} else {
			if (args.length > 0 && args[0].equals(version_option)) {
				print_version();
			}
			usage();
			Configuration.terminate(1);
		}
	}

	// Host name of the server
	public String hostname() {
		return hostname;
	}

	// Port number to use for the socket connection
	public int port_number() {
		return port_number;
	}

// Implementation

	private void usage() {
		System.err.println("Usage: MA_Client hostname port_number [options]\n"+
		"Options:\n   "+ symbol_option +" symbol ..." +
		"    Include only the specified symbols in the selection list.\n" +
		"   " + debug_option +
		"           Print debugging information.\n" +
		"   " + printall_option +
		"           Print the chart for each symbol.\n" +
		"   " + version_option +
		"               Print version information and exit.\n" +
		"   " + compression_option +
		"               Request compressed data from server."
		);
	}

	// Print version information and terminate.
	private void print_version() {
		MasProductInfo info = new MasProductInfo();
		String version_info = info.name() + ", Version " +
			info.release_description() + "\n" + "Date: " + info.date();
		System.out.println(version_info);
		Configuration.terminate(0);
	}

// Implementation - attributes

	protected String hostname = null;
	protected int port_number;
}
