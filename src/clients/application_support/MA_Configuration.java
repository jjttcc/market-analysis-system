/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_support;

import java.util.*;
import java.io.*;
import common.*;
import support.*;
import java.awt.*;

/** Global configuration settings - singleton */
public class MA_Configuration extends Configuration implements NetworkProtocol,
		MA_ConfigurationInterface {

// Initialization
	public MA_Configuration(Tokenizer in_source) {
		super(in_source);
		input_source = in_source;
		start_date_settings = new Vector();
		end_date_settings = new Vector();
		_upper_indicators = new Hashtable();
		_lower_indicators = new Hashtable();
		_indicator_order = new Vector();
		_vertical_indicator_lines = new Hashtable();
		_horizontal_indicator_lines = new Hashtable();
		setup_colors();
		indicator_groups = new IndicatorGroups();
		main_indicator_group = new MonoAxisIndicatorGroup();
		main_indicator_group.add_indicator(IndicatorGroups.Maingroup);
		load_settings(in_source);
		indicator_groups.add_group(main_indicator_group);
		if (modifier != null) {
			modifier.execute(this);
		}
	}

	// Refresh configuration settings from the input source, if it has changed.
	public void reload() {
		if (input_source.was_modified()) {
			load_settings(input_source);
		}
	}

// Access

	// The singleton instance
	public static MA_Configuration application_instance() {
		return (MA_Configuration) _instance;
	}

	// Graph styles
	public final static int Candle_graph = 1, Regular_graph = 2;

	public String session_settings() {
		StringBuffer result = new StringBuffer();
		int i;
		DateSetting ds;

		if (start_date_settings.size() > 0) {
			for (i = 0; i < start_date_settings.size() - 1; ++i)
			{
				ds = (DateSetting) start_date_settings.elementAt(i);
				result.append(Start_date + Message_field_separator +
					ds.time_period() + Message_field_separator + ds.date() +
					Message_field_separator);
			}
			ds = (DateSetting) start_date_settings.elementAt(i);
			result.append(Start_date + Message_field_separator +
				ds.time_period() + Message_field_separator + ds.date());
		}
		if (end_date_settings.size() > 0) {
			result.append(Message_field_separator);
			for (i = 0; i < end_date_settings.size() - 1; ++i)
			{
				ds = (DateSetting) end_date_settings.elementAt(i);
				result.append(End_date + Message_field_separator +
					ds.time_period() + Message_field_separator + ds.date() +
					Message_field_separator);
			}
			ds = (DateSetting) end_date_settings.elementAt(i);
			result.append(End_date + Message_field_separator +
				ds.time_period() + Message_field_separator + ds.date());
		}
		return result.toString();
	}

	// Is 'c' a valid color to use for set_color?
	public boolean valid_color(String c) {
		return c != null && _color_table.containsKey(c);
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

	// Color to use for indicator lines
	public Color line_color() {
		return _line_color;
	}

	// Color to use for reference lines
	public Color reference_line_color() {
		return _reference_line_color;
	}

	// Color to use for text
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

	// Color for `color_name' - null if `color_name' is not valid
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

// Element change

	// Set the configuration modifier to 'm'.
	public static void set_modifier(ConfigurationModifier m) {
		modifier = m;
	}

	// Set the color of the element specified by 'color_tag' to 'color'.
	public void set_color(String color_tag, String color) {
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
		else if (color_tag.equals(Reference_line_color)) {
			_reference_line_color = (Color) _color_table.get(color);
		}
		else if (color_tag.equals(Text_color)) {
			_text_color = (Color) _color_table.get(color);
		}
		else {
			System.err.println("Invalid color tag: " + color_tag);
		}
	}

	// Set the main graph style to 'style'.
	// Precondition: style.equals(Candle_style) || style.equals(Regular_style)
	public void set_main_graph_style(String style) {
		set_graph_style(Main_graph_style, style);
	}

// Constants

	// Configuration Keywords
	public static final String Upper_indicator = "upper_indicator";
	public static final String Lower_indicator = "lower_indicator";
	public static final String Horiz_indicator_line = "indicator_line_h";
	public static final String Vert_indicator_line = "indicator_line_v";
	public static final String Color_tag = "color";
	public static final String Background_color = "background_color";
	public static final String Black_candle_color = "black_candle_color";
	public static final String White_candle_color = "white_candle_color";
	public static final String Stick_color = "stick_color";
	public static final String Bar_color = "bar_color";
	public static final String Line_color = "line_color";
	public static final String Reference_line_color = "reference_line_color";
	public static final String Text_color = "text_color";
	public static final String Main_graph_style = "main_graph_style";
	public static final String Candle_style = "candle";
	public static final String Regular_style = "regular";
	public static final String Indicator_group = "indicator_group";
	public static final String End_block = "end_block";

// Implementation

	private void load_settings(Tokenizer input) {
		String s;
		if (input == null) {
			// No input source - use default settings.
			DateSetting ds = new DateSetting("1998/05/01",
				Daily_period_type);
			start_date_settings.addElement(ds);
			ds = new DateSetting("now", Daily_period_type);
			end_date_settings.addElement(ds);
		} else {
			try {
				input.tokenize("\n");
			} catch (IOException e) {
				System.err.println("I/O error occurred while " +
					"reading " + input.description() + ": " + e);
				terminate(-1);
			}
			while (! input.exhausted()) {
				StringTokenizer t =
					new StringTokenizer(input.item(), "\t");
				s = t.nextToken();
				if (s.charAt(0) == '#') {	// skip comment line
				} else if (s.equals(Start_date)) {
					add_date(t, true, input.description());
				} else if (s.equals(End_date)) {
					add_date(t, false, input.description());
				} else if (s.equals(Upper_indicator)) {
					configure_indicator(t, true);
				} else if (s.equals(Lower_indicator)) {
					configure_indicator(t, false);
				} else if (s.equals(Horiz_indicator_line) ||
							s.equals(Vert_indicator_line)) {
					add_indicator_line(s, t);
				} else if (s.endsWith(Color_tag)) {
					set_color(s, t.nextToken());
				} else if (s.equals(Main_graph_style)) {
					set_graph_style(s, t.nextToken());
				} else if (s.equals(Indicator_group)) {
					input.forth();
					create_indicator_group(input);
				}
				input.forth();
			}
		}
	}

	private void add_indicator_line(String line_type, StringTokenizer t) {
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

	private void add_date(StringTokenizer t, boolean start,
			String input_description) {
		String pertype = t.nextToken();
		String date = t.nextToken();
		if (date == null || pertype == null) {
			System.err.println("Missing period type or date in " +
				input_description);
			terminate(-1);
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

	// Create an indicator group for the indicators listed at "input"'s current
	// position and add it to `indicator_groups'.
	// Precondition: "input".item() is the line following the line with the
	// Indicator_group token that begins a group definition.
	private void create_indicator_group(Tokenizer input) {
		IndicatorGroup g = new MonoAxisIndicatorGroup();
		while (! input.exhausted() && !input.item().equals(End_block)) {
			g.add_indicator(input.item());
			input.forth();
		}
		indicator_groups.add_group(g);
		if (input.exhausted()) {
			System.err.println("Missing " + End_block + " token in " +
				input.description());
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
		red = (float) 0.6; green = (float) 0.6; blue = (float) 0.7;
		_color_table.put("softBlue", new Color(red, green, blue));
		red = (float) 0.9; green = (float) 0.6; blue = (float) 0.6;
		_color_table.put("softRed", new Color(red, green, blue));
		red = (float) 0.55; green = (float) 0.75; blue = (float) 0.55;
		_color_table.put("softGreen", new Color(red, green, blue));
		_color_table.put("purple", new Color(204, 0, 102));

		// Set default colors.
		_background_color = Color.blue;
		_black_candle_color = Color.red;
		_white_candle_color = Color.green;
		_stick_color = Color.white;
		_bar_color = Color.green;
		_line_color = Color.cyan;
		_reference_line_color = (Color) _color_table.get("softBlue");

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

// Implementation - attributes

	Tokenizer input_source;

	private static ConfigurationModifier modifier = null;

	private Vector start_date_settings;
	private Vector end_date_settings;
	private Hashtable _upper_indicators;
	private Hashtable _lower_indicators;
	private Vector _indicator_order;
	private Hashtable _vertical_indicator_lines;
	private Hashtable _horizontal_indicator_lines;
	private Hashtable _color_table;
	private Hashtable reverse_color_table;
	private IndicatorGroups indicator_groups;
	private IndicatorGroup main_indicator_group;

	// Color settings for graph components
	private Color _background_color;
	private Color _black_candle_color;
	private Color _white_candle_color;
	private Color _stick_color;
	private Color _bar_color;
	private Color _line_color;
	private Color _reference_line_color;
	private Color _text_color;
	// "null" color - needed because dorky Java doesn't allow a null value
	// in a hash table.
	private Color _null_color;

	private int _main_graph_drawer;

	private class DateSetting {
		DateSetting(String dt, String period) {
			date = dt; time_period = period;
		}

		public String date() { return date; }
		public String time_period() { return time_period; }

		private String date;
		private String time_period;
	}
}
