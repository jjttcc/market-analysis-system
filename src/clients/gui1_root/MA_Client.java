/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;
import mas_gui.*;

/** Root class for the Market Analysis client process */
public class MA_Client {
	public static void main(String[] args) {
		mas_gui.DataSetBuilder data_builder =
			new mas_gui.DataSetBuilder(connection());
		mas_gui.Chart chart;
		chart = new mas_gui.Chart(data_builder, chart_filename,
			command_line_options());
	}

	private static mas_gui.Connection connection() {
		//!!!!Stub - Need to parse arguments, create options object,
		//create io connection, connection, etc.
		mas_gui.Connection result =
null;

		return result;
	}

	private static mas_gui.MAS_Options command_line_options() {
		//!!!!!Stub
		mas_gui.MAS_Options result =
null;

		return result;
	}

	private static final String chart_filename = ".ma_client_settings";
}
