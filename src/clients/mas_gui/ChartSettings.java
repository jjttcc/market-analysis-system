package mas_gui;

import java.awt.*;
import java.util.*;
import java.io.*;
import application_library.WindowSettings;

/**
* Persistent chart-window settings
**/
class ChartSettings implements Serializable {

	public ChartSettings(Dimension sz, Properties printprop, Point loc,
			Vector upperind, Vector lowerind, boolean replace_ind) {
		size_ = sz;
		print_properties_ = printprop;
		location_ = loc;
		upper_indicators_ = upperind;
		lower_indicators_ = lowerind;
		replace_indicators_ = replace_ind;
		window_settings = new Hashtable();
	}
	public Dimension size() { return size_; }
	public Point location() { return location_; }
	public Properties print_properties() { return print_properties_; }
	public Vector upper_indicators() { return upper_indicators_;}
	public Vector lower_indicators() { return lower_indicators_;}
	public boolean replace_indicators() { return replace_indicators_; }
	public WindowSettings wsettings(String title) {
		WindowSettings result = (WindowSettings) window_settings.get(title);
		return result;
	}
	public void add_window_setting(WindowSettings ws, String title) {
		window_settings.put(title, ws);
	}

	private Dimension size_;
	private Properties print_properties_;
	private Point location_;
	private Vector upper_indicators_;
	private Vector lower_indicators_;
	private boolean replace_indicators_;
	private Hashtable window_settings;
}
