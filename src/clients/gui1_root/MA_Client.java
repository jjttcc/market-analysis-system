/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;

/** Root class for the Market Analysis client process */
public class MA_Client {
	public static void main(String[] args) throws IOException {
		DataSetBuilder data_builder = new DataSetBuilder(args);
		Chart chart;
		chart = new Chart(data_builder, chart_filename);
	}

	private static final String chart_filename = ".ma_client_settings";
}
