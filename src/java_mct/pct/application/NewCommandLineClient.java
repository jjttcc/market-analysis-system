package pct.application;

import java.io.*;

// Plug-in to start a new MAS command-line client process
public class NewCommandLineClient extends MCT_Constants {
	public NewCommandLineClient(Object pcontext) {
		super(pcontext);
	}

	public Object execute() {
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
			String cmd = processed_command(
				(String) settings.get(command_line_cmd_key));
System.out.println("Trying to execute: " + cmd);
			Process p = runtime.exec(cmd);
		} catch (Exception e) {
			System.err.println("Error: failed to start mas command-line " +
				"client: " + e);
		}
		return result;
	}

	Runtime runtime;
}
