/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package support;

import java.util.*;
import java.io.*;
import common.*;
import support.*;
import java.awt.*;

/** Global configuration settings - singleton */
public class Configuration implements NetworkProtocol
{
	// Graph styles
	public final int Candle_graph = 1, Regular_graph = 2;

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
	// the bottom one
	public Hashtable upper_indicators() {
		return _upper_indicators;
	}

	// Indicators configured to be drawn in the lower graph
	public Hashtable lower_indicators() {
		return _lower_indicators;
	}

	// Vertical lines coordinates configured for `indicator' - null if none.
	public Vector vertical_indicator_lines_at(String indicator) {
		return (Vector) _vertical_indicator_lines.get(indicator);
	}

	// Horizontal lines coordinates configured for `indicator' - null if none.
	public Vector horizontal_indicator_lines_at(String indicator) {
		return (Vector) _horizontal_indicator_lines.get(indicator);
	}

	// Color to use for graph background
	public Color background_color() {
		return _background_color;
	}

	// Color to use for "black" candles
	public Color black_candle_color() {
		return _black_candle_color;
	}

	// Color to use for "white" candles
	public Color white_candle_color() {
		return _white_candle_color;
	}

	// Color to use for straight "sticks" (bar lines, etc.)
	public Color stick_color() {
		return _stick_color;
	}

	// Color to use for bar graphs
	public Color bar_color() {
		return _bar_color;
	}

	// Color to use for connecting lines (indicators)
	public Color line_color() {
		return _line_color;
	}

	// Color to use for connecting lines (indicators)
	public Color text_color() {
		return _text_color;
	}

	// User-specified color for indicator `i' - null if not specified
	public Color indicator_color(String i, boolean upper) {
		Color result;

		if (upper) {
			result = (Color) _upper_indicators.get(i);
		} else {
			result = (Color) _lower_indicators.get(i);
		}
		if (result == _null_color) result = null;

		return result;
	}

	// The name for `c'
	public String color_name(Color c) {
		return (String) reverse_color_table.get(c);
	}

	// Color for `color_name'
	public Color color(String color_name) {
		return (Color) _color_table.get(color_name);
	}

	// List of indicators in their user-specified order
	public Vector indicator_order() {
		return _indicator_order;
	}

	public int main_graph_drawer() {
		return _main_graph_drawer;
	}

	public IndicatorGroups indicator_groups() {
		return indicator_groups;
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
		_lower_indicators = new Hashtable();
		_indicator_order = new Vector();
		_vertical_indicator_lines = new Hashtable();
		_horizontal_indicator_lines = new Hashtable();
		setup_colors();
		indicator_groups = new IndicatorGroups();
		main_indicator_group = new IndicatorGroup();
		main_indicator_group.add_indicator(IndicatorGroups.Maingroup);
		load_settings(configuration_file);
		indicator_groups.add_group(main_indicator_group);
	}

	private void load_settings(String fname) {
		String s;
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
					add_date(t, true);
				}
				else if (s.equals(End_date)) {
					add_date(t, false);
				}
				else if (s.equals(Upper_indicator)) {
					configure_indicator(t, true);
				}
				else if (s.equals(Lower_indicator)) {
					configure_indicator(t, false);
				}
				else if (s.equals(Horiz_indicator_line) ||
							s.equals(Vert_indicator_line)) {
					add_indicator_line(s, t);
				}
				else if (s.endsWith(Color_tag)) {
					set_color(s, t);
				}
				else if (s.equals(Main_graph_style)) {
					set_graph_style(s, t.nextToken());
				}
				else if (s.equals(Indicator_group)) {
					file_util.forth();
					create_indicator_group(file_util);
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
	}

	private void set_color(String color_tag, StringTokenizer t) {
		String color = t.nextToken();
		if (! _color_table.containsKey(color)) {
			System.err.println("Invalid color setting for " + color_tag +
								": '" + color + "'");
		}
		else if (color_tag.equals(Background_color)) {
			_background_color = (Color) _color_table.get(color);
		}
		else if (color_tag.equals(Black_candle_color)) {
			_black_candle_color = (Color) _color_table.get(color);
		}
		else if (color_tag.equals(White_candle_color)) {
			_white_candle_color = (Color) _color_table.get(color);
		}
		else if (color_tag.equals(Stick_color)) {
			_stick_color = (Color) _color_table.get(color);
		}
		else if (color_tag.equals(Bar_color)) {
			_bar_color = (Color) _color_table.get(color);
		}
		else if (color_tag.equals(Line_color)) {
			_line_color = (Color) _color_table.get(color);
		}
		else if (color_tag.equals(Text_color)) {
			_text_color = (Color) _color_table.get(color);
		}
		else {
			System.err.println("Invalid color tag: " + color_tag);
		}
	}

	private void add_date(StringTokenizer t, boolean start) {
		String pertype = t.nextToken();
		String date = t.nextToken();
		if (date == null || pertype == null)
		{
			System.err.println("Missing period type or date" +
				"in configuration file " + configuration_file);
			System.exit(-1);
		}
		DateSetting ds = new DateSetting(date, pertype);
		if (start) start_date_settings.addElement(ds);
		else end_date_settings.addElement(ds);
	}

	// Put the group specified in `t' into the appropriate container -
	// upper or lower, record its position for the indicator order, record
	// its color (if specified), and, if `upper', add it to the main group.
	private void configure_indicator(StringTokenizer t, boolean upper) {
		if (t.hasMoreElements()) {
			String indicator = t.nextToken();
			Color color = _null_color;
			// If the color is specified, scan it.
			if (t.hasMoreElements()) {
				String c = t.nextToken();
				if (! _color_table.containsKey(c)) {
					System.err.println("Invalid color setting for " +
						"indicator: " + c);
				} else {
					color = (Color) _color_table.get(c);
				}
			}
			if (upper) {
				_upper_indicators.put(indicator, color);
				main_indicator_group.add_indicator(indicator);
			} else {
				_lower_indicators.put(indicator, color);
			}
			_indicator_order.addElement(indicator);
		}
	}

	// Create an indicator group for the indicators listed at f's current
	// position and add it to `indicator_groups'.
	// Precondition: f.item() is the line following the line with the
	// Indicator_group token that begins a group definition.
	private void create_indicator_group(FileReaderUtilities f) {
		IndicatorGroup g = new IndicatorGroup();
		while (! f.exhausted() && !f.item().equals(End_block)) {
			g.add_indicator(f.item());
			f.forth();
		}
		indicator_groups.add_group(g);
		if (f.exhausted()) {
			System.err.println("Missing " + End_block + " token in " +
				"configuration file.");
		}
	}

	private void set_graph_style(String tag, String style) {
		if (tag.equals(Main_graph_style)) {
			if (style.equals(Candle_style)) {
				_main_graph_drawer = Candle_graph;
			}
			else if (style.equals(Regular_style)) {
				_main_graph_drawer = Regular_graph;
			}
		}
		else {
			// no other graph styles for now
		}
	}

	void setup_colors() {
		_color_table = new Hashtable();
		_color_table.put("white", Color.white);
		_color_table.put("lightGray", Color.lightGray);
		_color_table.put("gray", Color.gray);
		_color_table.put("darkGray", Color.darkGray);
		_color_table.put("black", Color.black);
		_color_table.put("red", Color.red);
		_color_table.put("pink", Color.pink);
		_color_table.put("orange", Color.orange);
		_color_table.put("yellow", Color.yellow);
		_color_table.put("green", Color.green);
		_color_table.put("magenta", Color.magenta);
		_color_table.put("cyan", Color.cyan);
		_color_table.put("blue", Color.blue);

		float red = (float) 0.4875, green = (float) 0.5875,
		blue = (float) 0.1875;
		_color_table.put("oliveGreen", new Color(red, green, blue));
		red = (float) 0.1875; green = (float) 0.4875; blue = (float) 0.1875;
		_color_table.put("darkGreen", new Color(red, green, blue));
		red = (float) 0.1875; green = (float) 0.1875; blue = (float) 0.45;
		_color_table.put("darkBlue", new Color(red, green, blue));
		red = (float) 0.425; green = (float) 0.425; blue = (float) 0.9;
		_color_table.put("lightBlue", new Color(red, green, blue));
		_color_table.put("purple", new Color(204, 0, 102));

		// Set default colors.
		_background_color = Color.blue;
		_black_candle_color = Color.red;
		_white_candle_color = Color.green;
		_stick_color = Color.white;
		_bar_color = Color.green;
		_line_color = Color.cyan;

		red = (float) 0.001; green = (float) 0.999; blue = (float) 0.0015;
		_null_color = new Color(red, green, blue);

		reverse_color_table = new Hashtable();
		Enumeration e = _color_table.keys();
		String s;
		while (e.hasMoreElements()) {
			s = (String) e.nextElement();
			reverse_color_table.put(_color_table.get(s), s);
		}
	}

	private static Configuration _instance;

	private Vector start_date_settings;
	private Vector end_date_settings;
	private final String configuration_file = ".ma_clientrc";
	private Hashtable _upper_indicators;
	private Hashtable _lower_indicators;
	private Vector _indicator_order;
	private Hashtable _vertical_indicator_lines;
	private Hashtable _horizontal_indicator_lines;
	private Hashtable _color_table;
	private Hashtable reverse_color_table;
	private IndicatorGroups indicator_groups;
	private IndicatorGroup main_indicator_group;

	// Configuration Keywords
	private final String Upper_indicator = "upper_indicator";
	private final String Lower_indicator = "lower_indicator";
	private final String Horiz_indicator_line = "indicator_line_h";
	private final String Vert_indicator_line = "indicator_line_v";
	private final String Color_tag = "color";
	private final String Background_color = "background_color";
	private final String Black_candle_color = "black_candle_color";
	private final String White_candle_color = "white_candle_color";
	private final String Stick_color = "stick_color";
	private final String Bar_color = "bar_color";
	private final String Line_color = "line_color";
	private final String Text_color = "text_color";
	private final String Main_graph_style = "main_graph_style";
	private final String Candle_style = "candle";
	private final String Regular_style = "regular";
	private final String Indicator_group = "indicator_group";
	private final String End_block = "end_block";

	// Color settings for graph components
	private Color _background_color;
	private Color _black_candle_color;
	private Color _white_candle_color;
	private Color _stick_color;
	private Color _bar_color;
	private Color _line_color;
	private Color _text_color;
	// "null" color - needed because dorky Java doesn't allow a null value
	// in a hash table.
	private Color _null_color;

	private int _main_graph_drawer;

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
