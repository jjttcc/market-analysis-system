/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;
import mas_gui.*;
import support.*;
import application_support.*;

/** Root class for the stand-alone Market Analysis client process */
public class MA_Client {
	public static void main(String[] args) {
		initialize_configuration();
		command_line_options = new mas_gui.CommandLineOptions(args);
		mas_gui.DataSetBuilder data_builder =
			new mas_gui.DataSetBuilder(connection(), command_line_options);
		mas_gui.Chart chart;
		chart = new mas_gui.Chart(data_builder, chart_filename,
			command_line_options);
	}

	private static mas_gui.Connection connection() {
//		assert command_line_options != null;
		mas_gui.Connection result;

		String hostname = command_line_options.hostname();
		int port_number = command_line_options.port_number();

		// The stand-alone client uses sockets to talk to the server.
		support.IO_SocketConnection io_connection =
			new support.IO_SocketConnection(hostname, port_number);

		if (command_line_options.compression()) {
			result = new mas_gui.CompressedConnection(io_connection);
		} else {
			result = new mas_gui.MA_Connection(io_connection);
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

	private static mas_gui.CommandLineOptions command_line_options;

	private static final String chart_filename = ".ma_client_settings";
	private static final String configuration_file_name = ".ma_clientrc";
}
