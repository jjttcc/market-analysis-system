package pct;

import java.util.Vector;
import java.lang.reflect.*;
import pct.ProgramControlTerminal;
import pct.application.*;

// ProgramControlTerminal Component
class PCT_Component {

	public PCT_Component(ProgramControlTerminal the_owner) {
		owner = the_owner;
		parent_component_context = owner.component_context();
		cmd_args = null;
		prompt_setting = "";
		startup_cmd_class_setting = "";
		startup_cmd_method_setting = "";
		startup_cmd_args_setting = new Vector();
		config_file_name_setting = "";
		exit_after_startup_cmd_setting = false;
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
	Object execute_method(String cmdname, Object[] args)
			throws Exception {
		Object result = null;
		if (startup_command == null) {
			create_startup_command();
		}
		if (startup_command != null && startup_method != null) {
//System.out.println("LOOK: About to call " + startup_method);
			result = startup_method.invoke(startup_command, args);
//System.out.println("LOOK: Finished calling " + startup_method);
		} else {
			throw new Exception("Command " + cmdname + " not found.");
		}
		return result;
	}

	// Execute startup_cmd.
	void exec_startup_cmd() throws Exception {
		Object context = null;
		boolean exec_failed = false;
		String cmdname = startup_cmd_class_setting + "." +
			startup_cmd_method_setting;
		try {
			if (cmd_args == null ||
					cmd_args.length < startup_cmd_args_setting.size()) {
				cmd_args = new Object[startup_cmd_args_setting.size()];
			}
			context = execute_method(cmdname, cmd_args);
		} catch (Exception e) {
			System.err.println("Execution of command '" +
				cmdname + "' failed with the error:\n" + e);
			exec_failed = true;
		}
		if (! exec_failed && config_file_name_setting != "") {
			// If there is a config file, a sub-terminal needs to be run.
			ProgramControlTerminal pct =
				new ProgramControlTerminal(config_file_name_setting,
					owner.program_name, context);
			pct.execute();
		}
	}

	// Create, using reflection, the startup command of class `name'.
	protected void create_startup_command() {
		final String app_pkg = "pct.application.";
		String classname = app_pkg + startup_cmd_class_setting;
		try {
			Class the_class = Class.forName(classname);
			Class[] constructor_args = new Class[] {Object.class};
			Constructor constructor =
				the_class.getConstructor(constructor_args);
			startup_command =
				constructor.newInstance(new Object[] {
					parent_component_context});
			startup_method = the_class.getMethod(
				startup_cmd_method_setting, null);
		} catch (InstantiationException e) {
			System.err.println(e);
		} catch (IllegalAccessException e) {
			System.err.println(e);
		} catch (ClassNotFoundException e) {
			System.err.println(e);
		} catch (InvocationTargetException e) {
			System.err.println(e);
		} catch (NoSuchMethodException e) {
			System.err.println(e);
		}
	}

	ProgramControlTerminal owner;
	Object startup_command;		// "command" to be executed on "startup"
	Method startup_method;		// "method" to be executed on "startup"
	Object[] cmd_args;			// Arguments for "startup" command
		// Name of method to call on `startup_command'
		// for the command result, if it exists
	Object parent_component_context;

	// "settings" - Must be public for reflection, but regard as private
	public String prompt_setting;
	public String startup_cmd_class_setting;
	public String startup_cmd_method_setting;
	public Vector startup_cmd_args_setting;		// of String
	public String config_file_name_setting;
	public boolean exit_after_startup_cmd_setting;
}
