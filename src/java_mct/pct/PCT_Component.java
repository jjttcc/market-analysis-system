package pct;

import java.util.Vector;
import java.lang.reflect.*;
import pct.ProgramControlTerminal;
//import org.apache.regexp.*;
import plugins.*;

// ProgramControlTerminal Component
class PCT_Component {

	PCT_Component(ProgramControlTerminal the_owner) {
		owner = the_owner;
		cmd_args = null;
//!! If not used, remove: terminal_name = "";
		prompt_setting = "";
		startup_cmd_class_setting = "";
		startup_cmd_method_setting = "";
		startup_cmd_args_setting = new Vector();
		config_file_name_setting = "";
		import_module_setting = new Vector();
		exit_after_startup_cmd_setting = false;
	}

	public String prompt() { return prompt_setting; }

	public String startup_cmd_class() { return startup_cmd_class_setting; }

	public String startup_cmd_method() { return startup_cmd_method_setting; }

	public Vector startup_cmd_args() { return startup_cmd_args_setting; }

	public String config_file_name() { return config_file_name_setting; }

//!!Possibly not needed:
	public Vector import_module() { return import_module_setting; }

	public boolean exit_after_startup_cmd() {
		return exit_after_startup_cmd_setting;
	}

//!!Looks like this feature is not needed - if so remove; if not, uncomment:
//	void set_startup_cmd(String cmd) {
//		try {
//		//!!Check if \ is needed before (:
//		RE re = new RE(".*\\(");
//		if (re.match(cmd)) {
//			System.err.println("Parentheses are not allowed in " +
//				"config. file " + "startup_cmd spec.\n(Command was '" +
//				cmd + "'.)");
//			System.exit(-1);
//		} else {
//			startup_cmd_setting = cmd;
//		}
//		}
//		catch (Exception e) {
//			System.err.println("Code defect in set_startup_cmd");
//			System.exit(-1);
//		}
//	}

	// Add an argument to startup_cmd.
	void add_cmd_arg(String arg) {
		startup_cmd_args_setting.addElement(arg);
	}

	// Prepend the list `l' of arguments to startup_cmd.
	void prepend_cmd_args(Vector l) {
		for (int i = 0; i < l.size(); ++i) {
			startup_cmd_args_setting.insertElementAt(l.elementAt(i), 0);
		}
	}

	// Dynamically execute `method' of `cmdclass'.
	Vector import_and_execute(Vector modules, String cmdclass, String method,
			Object[] args) {
		Vector result = null;
		String cmdname = cmdclass + "." + method;
System.out.println("import_and_execute called with class.method: " +
cmdname);
		try {
			if (startup_command == null) {
System.out.println("Creating cmd object");
				create_startup_command(cmdclass);
System.out.println("Created cmd object: " + startup_command);
			}
System.out.println("stupcmd and meth: " + startup_command +
", " + startup_method);
			if (startup_command != null && startup_method != null) {
System.out.println("LOOK: About to call " + startup_method);
				startup_method.invoke(startup_command, args);
System.out.println("LOOK: Finished calling " + startup_method);
//!!Fix this:
//if startup_command has a last_result routine {
//result = (Vector) startup_method.invoke(result_method, null);
//}
			} else {
				throw new Exception("Command " + cmdname + " not found.");
			}
		} catch (InvocationTargetException e) {
			System.out.println(e);
		} catch (Exception e) {
			System.err.println("Execution of command '" +
				cmdname + "' failed with the error:\n" + e);
		}
System.out.println("returning " + result);
		return result;
	}

	// Import the import_modules and execute startup_cmd.
	void exec_startup_cmd() throws Exception {
		Vector exe_result;
		try {
			if (cmd_args == null ||
					cmd_args.length < startup_cmd_args_setting.size()) {
				cmd_args = new Object[startup_cmd_args_setting.size()];
			}
			exe_result = import_and_execute(import_module_setting,
				startup_cmd_class_setting, startup_cmd_method_setting,
				cmd_args);
System.out.println("result was " + exe_result);
		} catch (Exception e) {
			throw e;
		}
		if (config_file_name_setting != "") {
System.out.println("config_file_name != ''");
			// If there is a config file, a sub-terminal needs to be run.
System.out.println("A1");
			ProgramControlTerminal pct =
				new ProgramControlTerminal(config_file_name_setting,
					owner.program_name);
System.out.println("A2 - pct: " + pct);
			pct.set_args(exe_result);
			pct.main_loop();
System.out.println("A3");
		}
	}

	protected void create_startup_command(String name) {
		try {
			Class the_class = Class.forName(name);
			startup_command = the_class.newInstance();
			startup_method = the_class.getMethod(
				startup_cmd_method_setting, null);
System.out.println("made the method: " + startup_method);
		} catch (InstantiationException e) {
System.err.println("1");
			System.err.println(e);
		} catch (IllegalAccessException e) {
System.err.println("2");
			System.err.println(e);
		} catch (ClassNotFoundException e) {
System.err.println("3");
			System.err.println(e);
		} catch (NoSuchMethodException e) {
System.err.println("4");
			System.err.println(e);
		}
	}

	ProgramControlTerminal owner;
	Object startup_command;		// "command" to be executed on "startup"
	Method startup_method;		// "method" to be executed on "startup"
	Object[] cmd_args;			// Arguments for "startup" command
		// Name of method to call on `startup_command'
		// for the command result, if it exists
	static final String result_method = "last_result";
//!! If not used, remove:	String terminal_name;

	// "settings" - Must be public for reflection, but regard as private
	public String prompt_setting;
	public String startup_cmd_class_setting;
	public String startup_cmd_method_setting;
	public Vector startup_cmd_args_setting;		// of String
	public String config_file_name_setting;
//!!Possibly not needed:
	public Vector import_module_setting;		// of String
	public boolean exit_after_startup_cmd_setting;
}
