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
