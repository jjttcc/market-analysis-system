package pct.application;

import java.io.*;
import pct.ApplicationContext;
import pct.application.MCT_ApplicationContext;

// Plug-in to start a new MAS GUI process
public class NewGUI {
	public NewGUI(ApplicationContext ac, Object pcontext) {
		app_context = (MCT_ApplicationContext) ac;
		parent_context = (MCT_ComponentContext) pcontext;
		if (app_context == null) {
			System.err.println("NewGUI failed to get the application " +
				"context (MCT_ApplicationContext)");
			System.exit(-1);
		}
	}

	public Object execute() {
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
String tmp_cmd = "/opt/mas/bin/magc -h " + " " +
parent_context.server_host_name() + " " +
parent_context.server_port_number();
System.out.println("Trying to execute: " + tmp_cmd);
			Process p = runtime.exec(tmp_cmd);
		} catch (Exception e) {
			System.err.println("Error: failed to start mas GUI: " + e);
		}
		return result;
	}

	MCT_ApplicationContext app_context;
	MCT_ComponentContext parent_context;	// context of parent component
	Runtime runtime;
}
