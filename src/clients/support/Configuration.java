package support;

import java.util.*;
import java.io.*;
import common.*;
import support.*;
import java.awt.*;

/** Global configuration settings - singleton */
public class Configuration implements NetworkProtocol
{
	public String session_settings() {
		StringBuffer result = new StringBuffer();
		int i;
		DateSetting ds;

		for (i = 0; i < start_date_settings.size() - 1; ++i)
		{
			ds = (DateSetting) start_date_settings.elementAt(i);
			result.append(Start_date + "\t" + ds.time_period() + "\t" +
							ds.date() + "\t");
		}
		ds = (DateSetting) start_date_settings.elementAt(i);
		result.append(Start_date + "\t" + ds.time_period() + "\t" +
						ds.date());
		if (end_date_settings.size() > 0)
		{
			result.append("\t");
			for (i = 0; i < end_date_settings.size() - 1; ++i)
			{
				ds = (DateSetting) end_date_settings.elementAt(i);
				result.append(End_date + "\t" + ds.time_period() + "\t" +
								ds.date() + "\t");
			}
			ds = (DateSetting) end_date_settings.elementAt(i);
			result.append(End_date + "\t" + ds.time_period() + "\t" +
							ds.date());
		}
		return result.toString();
	}

	// Indicators configured to be drawn in the upper graph rather than
	// the bottom one.
	public Hashtable upper_indicators() {
		return _upper_indicators;
	}

	// Vertical lines coordinates configured for `indicator' - null if none.
	public Vector vertical_indicator_lines_at(String indicator) {
		return (Vector) _vertical_indicator_lines.get(indicator);
	}

	// Horizontal lines coordinates configured for `indicator' - null if none.
	public Vector horizontal_indicator_lines_at(String indicator) {
		return (Vector) _horizontal_indicator_lines.get(indicator);
	}

	//!!!Note: These colors should be made configurable.

	// Color to use for "black" candles
	public Color black_candle_color() {
		return Color.red;
	}

	// Color to use for "white" candles
	public Color white_candle_color() {
		return Color.green;
	}

	// Color to use for straight "sticks" (bar lines, etc.)
	public Color stick_color() {
		return Color.white;
	}

	// Color to use for connecting lines (indicators)
	public Color line_color() {
		return Color.cyan;
	}


	// The singleton instance
	public static Configuration instance() {
		if (_instance == null) {
			_instance = new Configuration();
		}
		return _instance;
	}

	protected Configuration() {
		start_date_settings = new Vector();
		end_date_settings = new Vector();
		_upper_indicators = new Hashtable();
		_vertical_indicator_lines = new Hashtable();
		_horizontal_indicator_lines = new Hashtable();
		load_settings(configuration_file);
	}

	private void load_settings(String fname) {
		String s, date, pertype;
		File f = new File(fname);
		if (! f.exists()) {
			//Default settings
			DateSetting ds = new DateSetting("1998/05/01", daily_period_type);
			start_date_settings.addElement(ds);
			ds = new DateSetting("now", daily_period_type);
			end_date_settings.addElement(ds);
		}
		else {
			FileReaderUtilities file_util = new FileReaderUtilities(fname);
			try {
				file_util.tokenize("\n");
			}
			catch (IOException e) {
				System.err.println("I/O error occurred while reading file " +
					fname + ": " + e);
				System.exit(-1);
			}
			while (! file_util.exhausted()) {
				StringTokenizer t = new StringTokenizer(file_util.item(), "\t");
				s = t.nextToken();
				if (s.charAt(0) == '#') {}	// skip comment line
				else if (s.equals(Start_date)) {
					pertype = t.nextToken();
					date = t.nextToken();
					if (date == null || pertype == null)
					{
						System.err.println("Missing period type or date" +
							"in configuration file " + configuration_file);
						System.exit(-1);
					}
					DateSetting ds = new DateSetting(date, pertype);
					start_date_settings.addElement(ds);
				}
				else if (s.equals(End_date)) {
					pertype = t.nextToken();
					date = t.nextToken();
					if (date == null || pertype == null)
					{
						System.err.println("Missing period type or date" +
							"in configuration file " + configuration_file);
						System.exit(-1);
					}
					DateSetting ds = new DateSetting(date, pertype);
					end_date_settings.addElement(ds);
				}
				else if (s.equals(Indicator)) {
					_upper_indicators.put(t.nextToken(), new Boolean(true));
				}
				else if (s.equals(Horiz_indicator_line) ||
							s.equals(Vert_indicator_line)) {
					add_indicator_line(s, t);
				}
				file_util.forth();
			}
		}
	}

	private void add_indicator_line(String line_type, StringTokenizer t)
	{
		Float n1, n2;
		String indicator_name = t.nextToken();
		String coordinates = t.nextToken();
		StringTokenizer u = new StringTokenizer(coordinates, " ");
		Vector lines = null;
		n1 = new Float(u.nextToken());
		n2 = new Float(u.nextToken());
		if (line_type.equals(Vert_indicator_line)) {
			lines = (Vector) _vertical_indicator_lines.get(indicator_name);
			if (lines == null) {
				lines = new Vector();
				_vertical_indicator_lines.put(indicator_name, lines);
			}
		}
		else if (line_type.equals(Horiz_indicator_line)) {
			lines = (Vector) _horizontal_indicator_lines.get(indicator_name);
			if (lines == null) {
				lines = new Vector();
				_horizontal_indicator_lines.put(indicator_name, lines);
			}
		}
		if (lines != null) {
			lines.addElement(n1);
			lines.addElement(n2);
		}
//indicator_line_h	Stochastic %K	30 30
	}

	private static Configuration _instance;

	private Vector start_date_settings;
	private Vector end_date_settings;
	private final String configuration_file = ".ta_clientrc";
	private Hashtable _upper_indicators;
	private Hashtable _vertical_indicator_lines;
	private Hashtable _horizontal_indicator_lines;

	private final String Indicator = "indicator";
	private final String Horiz_indicator_line = "indicator_line_h";
	private final String Vert_indicator_line = "indicator_line_v";

	private class DateSetting
	{
		DateSetting(String dt, String period)
		{
			_date = dt; _time_period = period;
		}

		public String date() { return _date; }
		public String time_period() { return _time_period; }

		private String _date;
		private String _time_period;
	}
}
