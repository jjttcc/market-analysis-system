package pct.application;

import java.io.*;

// Plug-in to start a new MAS command-line client process
public class ServerTermination extends MCT_Constants {
	public ServerTermination(Object pcontext) {
		super(pcontext);
	}

	public Object execute() {
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
System.out.println("STerm - " + server_termination_cmd_key + ": " +
settings.get(server_termination_cmd_key));
			String cmd = processed_command(
				(String) settings.get(server_termination_cmd_key));
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
