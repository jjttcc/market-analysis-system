package pct.application;

import pct.ApplicationContext;
import pct.application.MCT_ApplicationContext;

// Plug-in to start a new MAS server process
public class NewServer {
	public NewServer(ApplicationContext ac, Object pcontext) {
		app_context = (MCT_ApplicationContext) ac;
		parent_context = (MCT_ComponentContext) pcontext;
		if (app_context == null) {
			System.err.println("NewServer failed to get the application " +
				"context (MCT_ApplicationContext)");
			System.exit(-1);
		}
	}

static int tmp_port = 32348;
	public Object execute() {
		Object result = null;
		System.out.println("I am a stub for the new server command.");
		System.out.println("The context is: " + app_context);
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
String tmp_hostname = "jupiter";
String tmp_cmd = "/opt/mas/bin/mas -o -f , -b /opt/mas/lib/data/ibm.txt";
++tmp_port;
			Process p = runtime.exec( tmp_cmd + " " + tmp_port);
			result = new MCT_ComponentContext(p, tmp_hostname, tmp_port);
		} catch (Exception e) {
			System.err.println("Error: failed to start mas server.");
		}
		return result;
	}

	MCT_ApplicationContext app_context;
	MCT_ComponentContext parent_context;	// context of parent component
	Runtime runtime;
}
