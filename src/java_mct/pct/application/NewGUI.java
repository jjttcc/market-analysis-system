package pct.application;

import java.io.*;

// Plug-in to start a new MAS GUI process
public class NewGUI extends MCT_Constants {
	public NewGUI(Object pcontext) {
		super(pcontext);
	}

	public Object execute() {
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
			String cmd = processed_command(
				(String) settings.get(gui_cmd_key), parent_context);
System.out.println("Trying to execute: " + cmd);
			Process p = runtime.exec(cmd);
		} catch (Exception e) {
			System.err.println("Error: failed to start mas GUI: " + e);
		}
		return result;
	}

	Runtime runtime;
}
