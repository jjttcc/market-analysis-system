package pct.application;


// Plug-in to start a new MAS server process
public class NewServer extends MCT_Constants {
	public NewServer(Object pcontext) {
		super(pcontext);
	}

static int tmp_port = 32348;
	public Object execute() {
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
System.out.println("NewServer - " + server_cmd_key + ": " +
settings.get(server_cmd_key));
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

	Runtime runtime;
}
