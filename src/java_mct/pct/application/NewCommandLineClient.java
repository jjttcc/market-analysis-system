package pct.application;

import java.io.*;
import pct.ApplicationContext;
import pct.application.MCT_ApplicationContext;

// Plug-in to start a new MAS command-line client process
public class NewCommandLineClient {
	public NewCommandLineClient(ApplicationContext ac, Object pcontext) {
		app_context = (MCT_ApplicationContext) ac;
		parent_context = (MCT_ComponentContext) pcontext;
		if (app_context == null) {
			System.err.println("NewCommandLineClient failed to get the " +
				"application context (MCT_ApplicationContext)");
			System.exit(-1);
		}
	}

	public Object execute() {
System.out.println("NCLC.execute A");
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
System.out.println("NCLC.execute B");
String tmp_cmd = "xterm -e /opt/mas/bin/macl -h " + " " +
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

	MCT_ApplicationContext app_context;
	MCT_ComponentContext parent_context;	// context of parent component
	Runtime runtime;
}
