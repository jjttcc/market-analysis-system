/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

//import java.applet.*;
import javax.swing.*;
import java.awt.*;
import java.net.*;
import java.util.*;
import java.io.*;
import mas_gui.*;
import support.*;
import application_support.*;
import appinit.*;
import applet.*;

// The Market Analysis System charting applet
public class MAS_Applet extends JApplet {

	public void init() {
		try {
			initialize_applet();
			appinit = new AppletInitialization(this);
			appinit.initialize_configuration();
			if (appinit.initialization_succeeded()) {
				StartupOptions options = new AppletOptions();
				initialize_server_address();
				// Can't read files from an applet.
				DataSetBuilder data_builder =
					new DataSetBuilder(connection(), options);
				if (data_builder.login_failed()) {
					if (data_builder.server_response() != null) {
						report_error(data_builder.server_response());
					} else {
						report_error("Login to the server failed");
					}
				} else {
					appinit.start_gui(data_builder, null, options);
				}
			} else {
				report_error(appinit.init_error());
			}
		} catch (Exception e) {
			log("Login failed: " + e.toString());
//			e.printStackTrace();
			report_error("Login failed: " + e.toString());
			destroy();
		}
	}

	public String[][] getParameterInfo() {
		return appinit.parameter_info();
	}

	public void paint(Graphics g) {
		g.drawString(title, 20, 20);
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
//		assert host_name != null && server_address != null && port > 0;
	}

	private Connection connection() throws Exception {
//		assert server_address != null;
		Connection result;

		// The applet client uses an URL connection to talk to the server.
		IO_URL_Connection io_connection =
			new IO_URL_Connection(server_address);
		if (compression()) {
			result = new CompressedConnection(io_connection);
		} else {
			result = new MA_Connection(io_connection);
		}

		return result;
	}

	private void initialize_applet() {
		title = applet_title();
	}

// Implementation - utilities

	private void log(String msg) {
		if (debug) {
			showStatus(msg);
			System.out.println(msg + "\n");
		}
	}

	private boolean compression() {
		// @@For now, default to no compression.
		return false;
	}

	private void report_error(String msg) {
		new ErrorBox("Error", msg, new Frame());
	}

	private String applet_title() {
		String result = getParameter(Applet_title_name);
		if (result == null) {
			result = "";
		}
		return result;
	}

// Implementation - attributes
	AppletInitialization appinit;

	private String host_name = "";
	private int port = -1;
	private String log_msg;
	private String server_address = null;

	private final String servlet_path = "/mas/mas";
	private String title;

// Implementation - constants

	private final boolean debug = false;

	private final String Applet_title_name = "title";
}
