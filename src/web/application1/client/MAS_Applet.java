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

// The Market Analysis System charting applet
public class MAS_Applet extends JApplet {

	public void init() {
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
//					Chart chart = new Chart(data_builder, null, options);
					MDI_gui mdi = new mas_gui.MDI_gui(data_builder,
						null, options);
				}
			}
		} catch (Exception e) {
			log("Login failed: " + e.toString());
//			e.printStackTrace();
			report_error("Login failed: " + e.toString());
			destroy();
		}
	}

	public String[][] getParameterInfo() {
		String result[][] = {
			{MA_Configuration.Background_color, color_type, Bg_color_description},
			{MA_Configuration.Text_color, color_type, Text_color_description},
			{MA_Configuration.Line_color, color_type, Line_color_description},
			{MA_Configuration.Bar_color, color_type, Bar_color_description},
			{MA_Configuration.Stick_color, color_type, Stick_color_description},
			{MA_Configuration.Reference_line_color, color_type,
				Reference_line_color_description},
			{MA_Configuration.Black_candle_color, color_type,
				Black_candle_color_description},
			{MA_Configuration.White_candle_color, color_type,
				White_candle_color_description},
			{MA_Configuration.Main_graph_style, graph_type,
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
		String[] icon_names = MA_Configuration.icon_names();
		Hashtable icon_table = new Hashtable();
		MA_Configuration.set_icon_table(icon_table);
		initialization_succeeded = false;
		try {
			Configuration.set_instance(new MA_Configuration(new Tokenizer(
				new StringReader(SelfContainedConfiguration.contents()),
				"configuration settings")));
			Configuration.set_ignore_termination(true);
			MA_Configuration.set_modifier(
				new ParameterBasedConfigurationModifier(
				parameter_names(), parameter_values()));
			initialization_succeeded = true;
		} catch (IOException e) {
			report_error("Initialization failed: " + e);
		}
		for (int i = 0; i < icon_names.length; ++i) {
			URL url = url_for(icon_path + icon_names[i]);
			if (url != null) {
				icon_table.put(icon_names[i],
					new ImageIcon(url, "Icon for " + icon_names[i]));
			} else {
				//!!!Report: Failed to load icon for icon_names[i].
			}
		}
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

	//@@These features probably need to go into a separate class.
	private String[] parameter_names() {
		String[] result = {
			MA_Configuration.Background_color,
			MA_Configuration.Text_color,
			MA_Configuration.Line_color,
			MA_Configuration.Bar_color,
			MA_Configuration.Stick_color,
			MA_Configuration.Reference_line_color,
			MA_Configuration.Black_candle_color,
			MA_Configuration.White_candle_color,
			MA_Configuration.Main_graph_style,
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

	protected URL url_for(String filename) {
		URL codebase = getCodeBase();
		URL url = null;

		try {
			url = new URL(codebase, filename);
		} catch (java.net.MalformedURLException e) {
			//!!!Turn this into a proper error message:
			System.err.println("Couldn't create image: badly specified URL");
			return null;
		}
		return url;
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

	private final boolean debug = false;

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
	private static final String icon_path = "images/";
}
