/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

import java.applet.*;
import java.awt.*;
import java.net.*;
import java.io.*;
import mas_gui.*;
import support.IO_URL_Connection;
import support.Configuration;
import support.ErrorBox;

// Test applet that communicates with the servlet via serialization
public class MAS_Applet extends Applet {

	public void init() {
		log("init: Starting ...");
		log("Compiled at Mon Feb 17 03:52:08 MST 2003");
		try {
			Configuration.set_ignore_termination(true);
			StartupOptions options = new AppletOptions();
			log("init: A");
			initialize_server_address();
			log("init: B");
			Chart chart;
			// Can't read files from an applet.
			Configuration.set_use_config_file(false);
			log("init: C");
			DataSetBuilder data_builder = new DataSetBuilder(connection(),
				options);
			log("init: D");
			chart = new Chart(data_builder, null, options);
			log("init: E");
		} catch (Exception e) {
			log("Connection failed: " + e.toString());
			report_error("Connection failed: " + e.toString());
			destroy();
		}
		log("init: Exiting ...");
	}

	private Connection connection() throws Exception {
		assert server_address != null;
		Connection result;

		// The applet client uses an URL connection to talk to the server.
		IO_URL_Connection io_connection =
			new IO_URL_Connection(server_address);
		if (compression()) {
			result = new CompressedConnection(io_connection);
		} else {
			result = new Connection(io_connection);
		}

		return result;
	}

// Implementation - initialization

	// Postcondition: host_name != null && server_address != null && port > 0
	private void initialize_server_address() throws Exception {
		URL host_url = getCodeBase();
		host_name = host_url.getHost();
		port = host_url.getPort();
		if (port == -1) {
			port = 80;
		}
		server_address = "http://" + host_name + ":" + port + servlet_path;
		assert host_name != null && server_address != null && port > 0;
	}

// Implementation - utilities

	private void log(String msg) {
		showStatus(msg);
		System.out.println(msg + "\n");
	}

	private boolean compression() {
		// @@For now, default to no compression.
		return false;
	}

	private void report_error(String msg) {
		new ErrorBox("Error", msg, new Frame());
	}

// Implementation - attributes

	private String host_name = "";
	private int port = -1;
	private String log_msg;
	//!!!!Needs to be made configurable:
	private String servlet_path = "/mas/mas";
	private String server_address = null;
}
