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
import support.ParameterBasedConfigurationModifier;

// The Market Analysis System charting applet
public class MAS_Applet extends Applet {

	public void init() {
		log("Compiled at Sat Feb 22 22:17:09 MST 2003");
		try {
			initialize_applet();
			initialize_configuration();
			if (initialization_succeeded) {
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
					Chart chart = new Chart(data_builder, null, options);
				}
			}
		} catch (Exception e) {
			log("Login failed: " + e.toString());
			e.printStackTrace();
			report_error("Login failed: " + e.toString());
			destroy();
		}
	}

	public String[][] getParameterInfo() {
		String result[][] = {
			{Configuration.Background_color, color_type, Bg_color_description},
			{Configuration.Text_color, color_type, Text_color_description},
			{Configuration.Line_color, color_type, Line_color_description},
			{Configuration.Bar_color, color_type, Bar_color_description},
			{Configuration.Stick_color, color_type, Stick_color_description},
			{Configuration.Reference_line_color, color_type,
				Reference_line_color_description},
			{Configuration.Black_candle_color, color_type,
				Black_candle_color_description},
			{Configuration.White_candle_color, color_type,
				White_candle_color_description},
			{Configuration.Main_graph_style, graph_type,
				Graph_style_description},
		};
		return result;
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
			Configuration.set_modifier(new ParameterBasedConfigurationModifier(
				parameter_names(), parameter_values()));
			initialization_succeeded = true;
		} catch (IOException e) {
			report_error("Initialization failed: " + e);
		}
	}

	private void initialize_applet() {
		title = applet_title();
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

	//@@These features probably need to go into a separate class.
	private String[] parameter_names() {
		String[] result = {
			Configuration.Background_color,
			Configuration.Text_color,
			Configuration.Line_color,
			Configuration.Bar_color,
			Configuration.Stick_color,
			Configuration.Reference_line_color,
			Configuration.Black_candle_color,
			Configuration.White_candle_color,
			Configuration.Main_graph_style,
		};
		return result;
	}

	private String[] parameter_values() {
		String[] pnames = parameter_names();
		String[] result = new String[pnames.length];
		for (int i = 0; i < pnames.length; ++i) {
			result[i] = getParameter(pnames[i]);
		}
		return result;
	}

	private String applet_title() {
		String result = getParameter(Applet_title_name);
		if (result == null) {
			result = "";
		}
		return result;
	}

// Implementation - attributes

	private String host_name = "";
	private int port = -1;
	private String log_msg;
	private String server_address = null;
	private boolean initialization_succeeded;
	private final String servlet_path = "/mas/mas";
	private String title;

// Implementation - constants

	private final String Applet_title_name = "title";

	//@@These elements need to go into a separate class.
	private final String color_type = "color";
	private final String graph_type = "graph style";

	private final String Bg_color_description = "the background color";
	private final String Line_color_description = "the default indicator color";
	private final String Bar_color_description =
		"the color used for bar graphs";
	private final String Stick_color_description =
		"the color used for straight 'sticks' (bar lines, etc.)";
	private final String Reference_line_color_description =
		"the color used for reference lines";
	private final String Text_color_description = "the text color";
	private final String Black_candle_color_description =
		"the color used for black candles";
	private final String White_candle_color_description =
		"the color used for white candles";
	private final String Graph_style_description = "the price-graph style";
}
