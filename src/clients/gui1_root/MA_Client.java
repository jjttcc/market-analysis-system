/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;
import mas_gui.*;

/** Root class for the Market Analysis client process */
public class MA_Client {
	public static void main(String[] args) throws IOException {
		mas_gui.DataSetBuilder data_builder = new mas_gui.DataSetBuilder(args);
		mas_gui.Chart chart;
		chart = new mas_gui.Chart(data_builder, chart_filename);
	}

	private static final String chart_filename = ".ma_client_settings";
}
