// Program Control Terminal
// This program's purpose is to control a set of related
// programs.  This program uses a configuration file to determine what
// programs are to be controlled and how to start and stop them.
// The configuration file is located in by means of the pct.dir property
// (specifying the directory in which the file resides) and the pct.name
// property (specifying the file name), which can be set on startup.
// For example, on a UNIX system
// java -Dpct.dir=$PWD -Dpct.name=x_config PCT_Main 
// will start the program and tell it to look for the configuration file
// in the current directory and that its name is x_config.

package pct;

import pct.ProgramControlTerminal;
import pct.ApplicationInitialization;
import application.*;

public class PCT_Main {

	public static void main(String[] args) {
		try {
//!!This call can probably go away:
			initialize_application();

			ProgramControlTerminal pct =
				new ProgramControlTerminal(null, null, null);
			ApplicationContext.set_root_window(pct.window);
			pct.execute();
		}
		catch (Exception e) {
			abort(e.toString());
		}
	}

//!!This feature can probably go away:
	public final static String application_init_class_name =
		"pct.application.SpecializedApplicationInitialization";

//!!This feature can probably go away:
	static void initialize_application() {
		Class app_init_class = null;
		ApplicationInitialization ai = null;

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
	}

	public static void abort(String msg) {
		if (msg != null) {
			msg = msg + " - ";
		}
		msg = msg + "Exiting ...";
		System.err.println(msg);
		System.exit(-1);
	}
}
