package pct;

import java.util.Vector;
import java.lang.reflect.*;
import pct.ProgramControlTerminal;
import pct.application.*;

// ProgramControlTerminal Component
class PCT_Component {

	public PCT_Component(ProgramControlTerminal the_owner) {
		owner = the_owner;
		_application_context = owner.application_context();
		parent_component_context = owner.component_context();
		cmd_args = null;
//!! If not used, remove: terminal_name = "";
		prompt_setting = "";
		startup_cmd_class_setting = "";
		startup_cmd_method_setting = "";
		startup_cmd_args_setting = new Vector();
		config_file_name_setting = "";
		exit_after_startup_cmd_setting = false;
	}

	public ApplicationContext application_context() {
		return _application_context;
	}

	public String prompt() { return prompt_setting; }

	public String startup_cmd_class() { return startup_cmd_class_setting; }

	public String startup_cmd_method() { return startup_cmd_method_setting; }

	public Vector startup_cmd_args() { return startup_cmd_args_setting; }

	public String config_file_name() { return config_file_name_setting; }

	public boolean exit_after_startup_cmd() {
		return exit_after_startup_cmd_setting;
	}

	// Prepend the list `l' of arguments to startup_cmd.
	void prepend_cmd_args(Vector l) {
		for (int i = 0; i < l.size(); ++i) {
			startup_cmd_args_setting.insertElementAt(l.elementAt(i), 0);
		}
	}

	// Dynamically execute `method' of `cmdclass' with args and return
	// the resulting component context.
	Object import_and_execute(String cmdclass, String method, Object[] args) {
		Object result = null;
		String cmdname = cmdclass + "." + method;
//System.out.println("import_and_execute called with class.method: " +
//cmdname);
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
				result = startup_method.invoke(startup_command, args);
System.out.println("LOOK: Finished calling " + startup_method);
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
		Object context;
		try {
			if (cmd_args == null ||
					cmd_args.length < startup_cmd_args_setting.size()) {
				cmd_args = new Object[startup_cmd_args_setting.size()];
			}
			context = import_and_execute(startup_cmd_class_setting,
				startup_cmd_method_setting, cmd_args);
		} catch (Exception e) {
			throw e;
		}
		if (config_file_name_setting != "") {
System.out.println("config_file_name != ''");
			// If there is a config file, a sub-terminal needs to be run.
System.out.println("A1");
			ProgramControlTerminal pct =
				new ProgramControlTerminal(config_file_name_setting,
					owner.program_name, _application_context, context);
System.out.println("A2 - pct: " + pct);
			pct.execute();
System.out.println("A3");
		}
	}

	// Create, using reflection, the startup command of class `name'.
	protected void create_startup_command(String name) {
		final String app_pkg = "pct.application.";
		String classname = app_pkg + name;
		try {
System.out.println("x");
			Class the_class = Class.forName(classname);
			Class[] constructor_args = new Class[] {
				ApplicationContext.class, Object.class};
System.out.println("y");
			Constructor constructor =
				the_class.getConstructor(constructor_args);
System.out.println("z");
			startup_command =
				constructor.newInstance(new Object[] {
					_application_context, parent_component_context});
System.out.println("getting method " + startup_cmd_method_setting);
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
		} catch (InvocationTargetException e) {
System.err.println("3.5");
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
	ApplicationContext _application_context;
	Object parent_component_context;
//!! If not used, remove:	String terminal_name;

	// "settings" - Must be public for reflection, but regard as private
	public String prompt_setting;
	public String startup_cmd_class_setting;
	public String startup_cmd_method_setting;
	public Vector startup_cmd_args_setting;		// of String
	public String config_file_name_setting;
	public boolean exit_after_startup_cmd_setting;
}
