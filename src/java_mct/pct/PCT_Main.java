// Program Control Terminal
//!!Update:
// This program whose purpose is to control a set of related
// programs.  This program uses a configuration file to determine what
// programs are to be controlled and how to start and stop them.
// The configuration file is located in one of two ways:
// The environment variable PCT_CONFIG_FILE can be set to the absolute path
// of the configuration file.  If this variable is not set or if the
// specified file does not exist, a file named {name}_config, where {name}
// represents the file name of this script, is searched for in the
// directories specified in the PYTHONPATH environment variable.  The
// components of the variable are searched from left to right, and the
// first directory to contain a file of this name is used.  Since the
// default name of this script is pct, the default name of the configuration
// file is pct_config.  However, this can be changed by changing the name of
// this file.  For example, if you rename this file mct (standing for,
// perhaps, mail control terminal), a file named mct_config will be searched
// for as the congifuration file.

import java.util.Properties;

class PCT_Main {

	public static void main(String[] args) {
		try {
			ProgramControlTerminal pct =
				new ProgramControlTerminal(null, null);
			System.err.println("Main2");
			pct.main_loop();
		}
		catch (Exception e) {
			abort(e.toString());
		}
	}

	private static void abort(String msg) {
		if (msg != null) {
			msg = msg + " - ";
		}
		msg = msg + "Exiting ...";
		System.err.println(msg);
		System.exit(-1);
	}
}
