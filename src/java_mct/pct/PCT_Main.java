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

import pct.ProgramControlTerminal;
import pct.ApplicationContext;
import pct.ApplicationInitialization;
import pct.application.*;

class PCT_Main {

	public static void main(String[] args) {
		try {
			ApplicationContext app_context = application_context();
			ProgramControlTerminal pct =
				new ProgramControlTerminal(null, null, app_context, null);
			System.err.println("PCT_Main - calling pct.execute.");
			pct.execute();
		}
		catch (Exception e) {
			abort(e.toString());
		}
	}

	public final static String application_init_class_name =
		"pct.application.SpecializedApplicationInitialization";

	static ApplicationContext application_context() {
		Class app_init_class = null;
		ApplicationInitialization ai = null;
		ApplicationContext result;

		try {
			app_init_class = Class.forName(application_init_class_name);
			Object o = app_init_class.newInstance();
			ai = (ApplicationInitialization) o;
		} catch (Exception e) {
		}
		if (ai == null) {
			// User-specialized application class was not specified or
			// was specified incorrectly.
			ai = new ApplicationInitialization();
		}
		result = ai.context();
		return result;
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
