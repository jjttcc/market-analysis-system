/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package gui1_root;

import java.io.*;
import java.awt.*;
import java.awt.event.*;
import support.*;
import application_support.*;
import application_library.*;

/** Root class for the stand-alone Market Analysis client process */
public class MA_Client {
	public static void main(String[] args) {
		initialize_configuration();
		command_line_options = new CommandLineOptions(args);
		configure_options(command_line_options);
		mas_gui.DataSetBuilder data_builder =
			new mas_gui.DataSetBuilder(connection(), command_line_options);
		mas_gui.Chart chart;
		try {
			chart = new mas_gui.Chart(data_builder, chart_filename,
				command_line_options);
		} catch (Exception e) {
			String msg = "Abnormal event occurred.  Please check that the " +
				configuration_file_name + " file\nis in the appropriate " +
				"directory and that it is configured correctly.";
			msg += "\n[Diagnostics: " + e + "]";
			System.err.println(msg);
			ErrorBox b = new ErrorBox("Startup error", msg, new Frame());
			b.set_exit_on_close(1);
			e.printStackTrace();
		}
	}

	// Configure Configuration.instance() with applicable options
	// from `command_line_options'.
	private static void configure_options(
			CommandLineOptions command_line_options) {

		if (command_line_options.debug()) {
			Configuration.instance().set_debug(true);
		}
		if (command_line_options.auto_refresh()) {
			Configuration.instance().set_auto_refresh(true);
			Configuration.instance().set_auto_refresh_delay(
				command_line_options.auto_refresh_delay());
		}
	}

	private static Connection connection() {
//		assert command_line_options != null;
		Connection result;

		String hostname = command_line_options.hostname();
		int port_number = command_line_options.port_number();

		// The stand-alone client uses sockets to talk to the server.
		support.IO_SocketConnection io_connection =
			new support.IO_SocketConnection(hostname, port_number);

		if (command_line_options.compression()) {
			result = new CompressedConnection(io_connection);
		} else {
			result = new MA_Connection(io_connection);
		}

		return result;
	}

	private static void initialize_configuration() {
		try {
//			Configuration.set_input_source(new FileTokenizer(
//				configuration_file_name));
			Configuration.set_instance(new MA_Configuration(new FileTokenizer(
				configuration_file_name)));
		} catch (IOException e) {
			System.err.println("Failed to open configuration file: " +
				configuration_file_name);
		}
	}

	private static CommandLineOptions command_line_options;

	private static final String chart_filename = ".ma_client_settings";
	private static final String configuration_file_name = ".ma_clientrc";
}
