import java.util.Vector;
import ProgramControlTerminal;
import gnu.rex.*;

// ProgramControlTerminal Component
class PCT_Component {

	PCT_Component(ProgramControlTerminal the_owner) {
		owner = the_owner;
//!! If not used, remove: terminal_name = "";
		prompt = "";
		startup_cmd = "";
		startup_cmd_args = new Vector();
		config_file_name = "";
		import_modules = new Vector();
		exit_after_startup_cmd = 0;
	}

	void set_startup_cmd(String cmd) {
		try {
		//!!Check if \ is needed before (:
		Rex re = Rex.build(".*(");
		RexResult result = re.match(cmd.toCharArray(), 0, cmd.length());
		if (result != null) {
			//^^^^^^^^^^^^^^^^^if regex.match(".*(", cmd) != -1:
			System.err.println("Parentheses are not allowed in " +
				"config. file " + "startup_cmd spec.\n(Command was '" +
				cmd + "'.)");
			System.exit(-1);
		} else {
			startup_cmd = cmd;
		}
		}
		catch (Exception e) {
			System.err.println("Code defect in set_startup_cmd");
			System.exit(-1);
		}
	}

	// Add an argument to startup_cmd.
	void add_cmd_arg(String arg) {
		startup_cmd_args.addElement(arg);
	}

	// Prepend the list `l' of arguments to startup_cmd.
	void prepend_cmd_args(Vector l) {
		for (int i = 0; i < l.size(); ++i) {
			startup_cmd_args.insertElementAt(l.elementAt(i), 0);
		}
	}

	// Dynamically import `modules' and execute `cmd'.
	// Set args to empty string to indicate there are not arguments.
	Vector import_and_execute(Vector modules, String cmd, Vector args) {
		Vector result = null;
		System.out.println("import_and_execute called with cmd: " + cmd);
		for (int i = 0; i < modules.size(); ++i) {
			String import_stmt = "from " + modules.elementAt(i) + " import *";
			try {
				System.out.println("execing " + import_stmt);
				//exec import_stmt
				System.out.println("Execution of " + import_stmt +
					" succeeded.");
			} catch (Exception e) {
				System.err.println("Execution of " + import_stmt + " failed.");
			}
		}
		String complete_cmd = cmd + "(";
		if (! args.isEmpty()) {
			String lastarg = "";
			int i = -1;
			if (args.size() > 1) {
				for (i = 0; i < args.size() - 1; ++i) {
					lastarg = (String) args.elementAt(i);
					complete_cmd = complete_cmd + lastarg + ", ";
				}
			}
			lastarg = (String) args.elementAt(i+1);
			complete_cmd = complete_cmd + lastarg;
			//abort("Error parsing argument " + lastarg + " to " + cmd + \
			//	"\n(They must" + " be strings, not numbers.)")
		}
		complete_cmd = complete_cmd + ")";
		System.out.println("executing 'result' = " + complete_cmd + "'");
		try {
			//exec "result = " + complete_cmd
		} catch (Exception e) {
			//if str(sys.exc_info()[1]) == "0" {
			//	// no error
			//} else {
			//	raise "Execution of command '" + complete_cmd + "' failed." + \
			//		"with the error:\n" + str(sys.exc_info()[1])
			//}
		}
		System.out.println("returning " + result);
		return result;
	}

	// Import the import_modules and execute startup_cmd.
	void exec_startup_cmd() throws Exception {
		Vector exe_result;
		//print 'setting up cmd with imports: '
		//print self.import_modules
		try {
			exe_result = import_and_execute(import_modules, startup_cmd,
				startup_cmd_args);
			System.out.println("result was " + exe_result);
		} catch (Exception e) {
			throw e;
		}
		if (config_file_name != "") {
			System.out.println("config_file_name != ''");
			// If there is a config file, a sub-terminal needs to be run.
			ProgramControlTerminal pct =
				new ProgramControlTerminal(config_file_name,
					owner.program_name);
			pct.set_args(exe_result);
		}
	}

	ProgramControlTerminal owner;
//!! If not used, remove:	String terminal_name;
	String prompt;
	String startup_cmd;
	Vector startup_cmd_args;		// of String
	String config_file_name;
	Vector import_modules;		// of String
	int exit_after_startup_cmd;
}
