/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

import java.applet.*;
import java.awt.*;
import java.net.*;
import java.io.*;
import mas_gui.*;

// Test applet that communicates with the servlet via serialization
public class MAS_Applet extends Applet {
	public void paint(Graphics g) {
		if (logMsg != null) {
			g.drawString(logMsg, 5, 50);
		}
	}

	public void init() {
		try {
			initialize();
			Chart chart;
//!!!Stub:
			Connection c = null;
			DataSetBuilder data_builder = new mas_gui.DataSetBuilder(c);
			chart = new mas_gui.Chart(data_builder, chart_filename, null);
		} catch (Exception e) {
			log("Connection failed: " + e.toString());
		}
	}

//!!!!!!!Temporary - need to fix:
private static final String chart_filename = ".ma_client_settings";

// Implementation - initialization

	// Postcondition: hostName != null && serverAddress != null &&
	//    port > 0 && connection != null
	private void initialize() throws Exception {
		URL hostURL = getCodeBase();
		hostName = hostURL.getHost();
		port = hostURL.getPort();
		if (port == -1)
		{
			port = 80;
		}
		serverAddress = "http://" + hostName + ":" + port + servletPath;
		connection = serverConnection();
		assert hostName != null && serverAddress != null && port > 0 &&
			connection != null;
	}

// Implementation - utilities

	// Connection to the server for binary input and ouput with caching off
	// Precondition: serverAddress != null
	private URLConnection serverConnection() throws Exception {
		URLConnection result = (new URL(serverAddress)).openConnection();

		result.setDoInput(true);
		result.setDoOutput(true);
		result.setUseCaches (false);
		result.setRequestProperty ("Content-Type",
			"application/octet-stream");
		return result;
	}

	private void log(String msg) {
		logMsg = msg;
	}

// Implementation - attributes

	private String hostName = "";
	private int port = -1;
	private String logMsg;
	private URLConnection connection;

	private String servletPath = "/mas/mas";
	private String serverAddress = null;
}
