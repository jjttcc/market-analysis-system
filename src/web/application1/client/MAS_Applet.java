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
import support.Tokenizer;
import support.SelfContainedConfiguration;

// The Market Analysis System charting applet
public class MAS_Applet extends Applet {

	public void init() {
		log("init: Starting ...");
		log("Compiled at Wed Feb 19 15:57:40 MST 2003");
		try {
			log("init: A");
			initialize_configuration();
			if (initialization_succeeded) {
				StartupOptions options = new AppletOptions();
				initialize_server_address();
				// Can't read files from an applet.
				log("init: C");
				DataSetBuilder data_builder =
					new DataSetBuilder(connection(), options);
				log("init: D");
				if (data_builder.login_failed()) {
					if (data_builder.server_response() != null) {
						report_error(data_builder.server_response());
					} else {
						report_error("Login to the server failed");
					}
				} else {
					Chart chart = new Chart(data_builder, null, options);
				}
				log("init: E");
			}
		} catch (Exception e) {
			log("Login failed: " + e.toString());
			e.printStackTrace();
			report_error("Login failed: " + e.toString());
			destroy();
		}
		log("init: Exiting ...");
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

	private void initialize_configuration() {
		initialization_succeeded = false;
		try {
			Configuration.set_input_source(new Tokenizer(new StringReader(
				SelfContainedConfiguration.contents()),
				"configuration settings"));
			Configuration.set_ignore_termination(true);
			initialization_succeeded = true;
		} catch (IOException e) {
			report_error("Initialization failed: " + e);
		}
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
	private boolean initialization_succeeded;
}
