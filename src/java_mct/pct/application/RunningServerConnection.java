package pct.application;

import java.util.*;
import java.awt.*;
import support.FileReaderUtilities;
import support.ErrorBox;
import pct.ApplicationContext;

// Plug-in to connect to a running MAS server process
public class RunningServerConnection extends MCT_Constants {
	public RunningServerConnection(Object pcontext) {
		super(pcontext);
	}

	// Obtain hostname and port number from user and place into `hostname'
	// and `port_number', respectively.
	void get_hostname_and_port() {
		PortDialog d = new PortDialog(parent_window, hostname);
		d.show();
		port_number = d.selected_port();
		hostname = d.selected_hostname();
	}

	public Object execute() throws Exception {
		MCT_ComponentContext result = null;
		MAS_ConnectionUtilities connection;
		hostname = property_value(pcthostname_property);
		get_hostname_and_port();
		result = new MCT_ComponentContext(hostname, port_number);
		connection = new MAS_ConnectionUtilities(hostname,
			new Integer(port_number));
		if (! connection.server_is_alive()) {
			new ErrorBox("Failed to connect to mas server",
				"server appears to be not running or not available",
				parent_window);
			throw new Exception("Failed to connect to mas server - " +
				"server appears to be not running or not available");
		}
//System.out.println("mct context created with hostname: " +
//((MCT_ComponentContext) result).server_host_name() +
//", port #: " + ((MCT_ComponentContext) result).server_port_number());
		return result;
	}

	Frame parent_window = ApplicationContext.root_window();
	int port_number;
	String hostname;
}
