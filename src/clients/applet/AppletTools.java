package applet;

import java.io.*;
import java.applet.*;
import java.net.*;
import mas_gui.*;
import application_support.*;
import support.*;

// Applet-related utilities
public class AppletTools {

	public AppletTools() {
	}

	// Parameter information to supply to Applet.getParameterInfo
	public String[][] parameter_info() {
		String result[][] = {
			{MA_Configuration.Background_color, color_type,
			Bg_color_description},
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

	// The URL for the specified file name
	protected URL url_for(String filename, Applet applet) {
		URL codebase = applet.getCodeBase();
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

	protected String[] parameter_names() {
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

	protected String[] parameter_values(Applet applet) {
		String[] pnames = parameter_names();
		String[] result = new String[pnames.length];
		for (int i = 0; i < pnames.length; ++i) {
			result[i] = applet.getParameter(pnames[i]);
		}
		return result;
	}

	// "parameter info"
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
}
