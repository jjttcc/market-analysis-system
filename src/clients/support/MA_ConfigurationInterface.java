/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import common.*;
import java.awt.*;

/** Interface for MAS global configuration settings - singleton */
public interface MA_ConfigurationInterface extends NetworkProtocol {

// Access

	// Graph styles
	public final static int Candle_graph = 1, Regular_graph = 2;

	public String session_settings();

	// Is 'c' a valid color to use for set_color?
	public boolean valid_color(String c);

	// Indicators configured to be drawn in the upper graph rather than
	// the bottom one
	public Hashtable upper_indicators();

	// Indicators configured to be drawn in the lower graph
	public Hashtable lower_indicators();

	// Vertical lines coordinates configured for `indicator' - null if none.
	public Vector vertical_indicator_lines_at(String indicator);

	// Horizontal lines coordinates configured for `indicator' - null if none.
	public Vector horizontal_indicator_lines_at(String indicator);

	// Color to use for graph background
	public Color background_color();

	// Color to use for "black" candles
	public Color black_candle_color();

	// Color to use for "white" candles
	public Color white_candle_color();

	// Color to use for straight "sticks" (bar lines, etc.)
	public Color stick_color();

	// Color to use for bar graphs
	public Color bar_color();

	// Color to use for indicator lines
	public Color line_color();

	// Color to use for reference lines
	public Color reference_line_color();

	// Color to use for text
	public Color text_color();

	// User-specified color for indicator `i' - null if not specified
	public Color indicator_color(String i, boolean upper);

	// The name for `c'
	public String color_name(Color c);

	// Color for `color_name' - null if `color_name' is not valid
	public Color color(String color_name);

	// List of indicators in their user-specified order
	public Vector indicator_order();

	public int main_graph_drawer();

	public IndicatorGroups indicator_groups();

	// Set the color of the element specified by 'color_tag' to 'color'.
	public void set_color(String color_tag, String color);

	// Set the main graph style to 'style'.
	// Precondition: style.equals(Candle_style) || style.equals(Regular_style)
	public void set_main_graph_style(String style);

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

}
