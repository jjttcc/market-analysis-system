/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.util.*;

// Options specified on the command line
public class CommandLineOptions extends MAS_Options {

	public CommandLineOptions(String[] args) {
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
}
