package pct.application;

import java.io.*;

// Plug-in to start a new MAS command-line client process
public class ServerTermination {
	public ServerTermination(Object pcontext) {
		parent_context = (MCT_ComponentContext) pcontext;
	}

	public Object execute() {
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
String tmp_cmd = "bash /tmp/terminate_mas -h " +
parent_context.server_host_name() + " " +
parent_context.server_port_number();
System.out.println("Trying to execute: " + tmp_cmd);
			Process p = runtime.exec(tmp_cmd);
		} catch (Exception e) {
			System.err.println("Error: failed to start mas command-line " +
				"client: " + e);
		}
		return result;
	}

	MCT_ComponentContext parent_context;	// context of parent component
	Runtime runtime;
}
