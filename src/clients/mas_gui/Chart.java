/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.*;
import java.awt.event.*;
import java.util.Vector;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Properties;
import java.io.*;
import graph.*;
import support.*;
import common.*;
import java_library.support.*;
import application_support.*;
import application_library.*;

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

/** Market analysis GUI chart component */
public class Chart extends Frame implements Runnable, NetworkProtocol,
	AssertionConstants {

	public Chart(DataSetBuilder builder, String sfname, StartupOptions opt) {
		super("Chart");
		++window_count;
		data_builder = builder;
		options_ = opt;
		this_chart = this;
		Vector _tradables = null;
		saved_dialogs = new Vector();
		_indicators = null;

		serialize_filename = sfname;

		if (window_count == 1 && serialize_filename != null) {
			ChartSettings settings = null;
			try {
				// Read the settings file, if it exists.
				FileInputStream chartfile =
					new FileInputStream(serialize_filename);
				ObjectInputStream ios = new ObjectInputStream(chartfile);
				settings = (ChartSettings) ios.readObject();
				window_settings = settings;
			} catch (IOException e) {
				// Most likely the file hasn't been created yet - no error.
			} catch (ClassNotFoundException e) {
				System.err.println("Class not found!" + e);
			}
		}
		try {
			if (_tradables == null) {
				_tradables = data_builder.tradable_list();
				if (! _tradables.isEmpty()) {
					// Each tradable has its own period type list; but for now,
					// just retrieve the list for the first tradable and use
					// it for all tradables.
					_period_types = data_builder.trading_period_type_list(
						(String) _tradables.elementAt(0));
					if (data_builder.connection().error_occurred()) {
						abort(data_builder.connection().result().toString(),
							null);
					}
					current_period_type = initial_period_type(_period_types);
				} else {
					abort("Server's list of tradables is empty.", null);
				}
			}
		} catch (IOException e) {
			System.err.println("IO exception occurred: " + e + " - aborting");
			e.printStackTrace();
			quit(-1);
		}
		String s = null;
		if (_tradables != null && _tradables.size() > 0) {
			s = (String) _tradables.elementAt(0);
		}
		initialize_GUI_components(s);
	}

	public StartupOptions options() {
		return options_;
	}

	// List of all tradables in the server's database
	public Vector tradables() {
		Vector result = null;
		try {
			result = data_builder.tradable_list();
		}
		catch (IOException e) {
			System.err.println("IO exception occurred, bye ...");
			quit(-1);
		}
		return result;
	}

	// indicators
	// Postcondition: result != null
	public Hashtable indicators() {
		Hashtable result = null;
		if (_indicators == null || new_indicators) {
			new_indicators = false;
			Vector inds_from_server = data_builder.last_indicator_list();
			if (previous_open_interest != data_builder.open_interest() ||
					! Utilities.lists_match(inds_from_server,
					old_indicators_from_server)) {
				// The old indicators are not the same as the indicators
				// just obtained from the server (or there are not yet
				// any old indicators), so the indicator lists need to
				// be rebuilt.
				old_indicators_from_server = inds_from_server;
				make_indicator_lists(inds_from_server);
			}
			previous_open_interest = data_builder.open_interest();
		}
		if (data_builder.connection().error_occurred()) {
			new ErrorBox("Warning",
				"Error occurred retrieving indicator list.", this_chart);
		}
		if (_indicators != null) {
			result = _indicators;
		} else {
			result = new Hashtable();
		}
//		assert result != null: "Postcondition violation";
		return _indicators;
	}

	private void make_indicator_lists(Vector inds_from_server) {
		Enumeration ind_iter;
		String s;
		int ind_count = inds_from_server.size();
		Hashtable valid_indicators;
		if (ind_count > 0) {
			valid_indicators = new Hashtable(inds_from_server.size());
		} else {
			valid_indicators = new Hashtable();
		}
		ordered_indicator_list = new Vector();
		int i;
		for (i = 0; i < inds_from_server.size(); ++i) {
			Object o = inds_from_server.elementAt(i);
			valid_indicators.put(o, new Integer(i + 1));
		}
		// User-selected indicators, in order:
		ind_iter = MA_Configuration.application_instance().indicator_order().
			elements();
		_indicators = new Hashtable();
		Vector special_indicators = new Vector();
		special_indicators.addElement(No_lower_indicator);
		special_indicators.addElement(No_upper_indicator);
		special_indicators.addElement(Volume);
		if (data_builder.open_interest()) {
			special_indicators.addElement(Open_interest);
		}
		// Insert into _indicators all user-selected indicators that
		// are either in the list returned by the server or are one of
		// the special strings for no upper/lower indicator, volume,
		// or open interest.
		while (ind_iter.hasMoreElements()) {
			s = (String) ind_iter.nextElement();
			if (valid_indicators.containsKey(s)) {
				// Add valid indicators (from the server's point of view)
				// to both `_indicators' and `ordered_indicator_list'.
				_indicators.put(s, valid_indicators.get(s));
				ordered_indicator_list.addElement(s);
			}
			else {
				for (i = 0; i < special_indicators.size(); ++i) {
					if (s.equals(special_indicators.elementAt(i))) {
						// Add special indicators only to
						// `ordered_indicator_list'.
						ordered_indicator_list.addElement(s);
						special_indicators.removeElement(s);
						break;
					}
				}
			}
		}
		// Insert the special indicators (no-upper indicator, ...) if
		// they aren't already there.
		for (i = 0; i < special_indicators.size(); ++i) {
			s = (String) special_indicators.elementAt(i);
			if (!_indicators.containsKey(s)) {
				_indicators.put(s, new Integer(_indicators.size() + 1));
				ordered_indicator_list.addElement(s);
			}
		}

		// Update current_lower_indicators and current_upper_indicators:
		// remove any elements that are no longer valid.
		Vector remove_list = new Vector();
		for (ind_iter = current_lower_indicators.elements();
				ind_iter.hasMoreElements(); ) {
			s = (String) ind_iter.nextElement();
			if (! ordered_indicator_list.contains(s)) {
				remove_list.addElement(s);
			}
		}
		for (i = 0; i < remove_list.size(); ++i) {
			while (current_lower_indicators.lastIndexOf(
				remove_list.elementAt(i)) != -1) {
				current_lower_indicators.removeElement(
					remove_list.elementAt(i));
			}
		}
		remove_list.removeAllElements();
		for (ind_iter = current_upper_indicators.elements();
				ind_iter.hasMoreElements(); ) {
			s = (String) ind_iter.nextElement();
			if (! ordered_indicator_list.contains(s)) {
				remove_list.addElement(s);
			}
		}
		for (i = 0; i < remove_list.size(); ++i) {
			while (current_upper_indicators.lastIndexOf(
				remove_list.elementAt(i)) != -1) {
				current_upper_indicators.removeElement(
					remove_list.elementAt(i));
			}
		}
		if (ma_menu_bar != null) ma_menu_bar.update_indicators();
	}

	// Indicators in user-specified order
	public Vector ordered_indicators() {
		if (ordered_indicator_list == null) {
			// Force creation of ordered_indicator_list.
			indicators();
		}
		return ordered_indicator_list;
	}

	// Result of last request to the server
	public int request_result_id() {
		return data_builder.request_result_id();
	}

	// Register `d' to save its size and location on exit with its title
	// as a key.
	public void register_dialog_for_save_settings(Dialog d) {
		saved_dialogs.addElement(d);
	}

	// Settings for dialog with title `s'
	public WindowSettings settings_for(String s) {
		WindowSettings result = null;
		if (window_settings != null) {
			result = window_settings.wsettings(s);
		}
		return result;
	}

	// Take action when notified that period type changed.
	void notify_period_type_changed(String new_period_type) {
		if (! current_period_type.equals(new_period_type)) {
			current_period_type = new_period_type;
			period_type_change = true;
			if (current_tradable != null) {
				request_data(current_tradable);
				//@@Replace with:
				//send_data_request(current_tradable);
				//if it turns out needing to not be threaded.
			}
		}
	}

	// Request data for the specified tradable and display it, using
	// a thread for efficiency.
	void request_data(String tradable) {
		requested_tradable = tradable;
		new Thread(this).start();
	}

	public void run() {
		//@@In the future, if needed, this routine can call one of a
		//set of routines, based on a flag.
		synchronized(requesting_data) {
			if (! requesting_data.booleanValue()) {
				Thread.yield();
				requesting_data = Boolean.TRUE;
				send_data_request(requested_tradable);
				requesting_data = Boolean.FALSE;
			} else {
			}
		}	// end synchronized block
	}

	void send_data_request(String tradable) {
		DataSet dataset, main_dataset;
		MA_Configuration conf = MA_Configuration.application_instance();
		int count;
		String current_indicator;
		// Don't redraw the data if it's for the same tradable as before.
		if (period_type_change || ! tradable.equals(current_tradable)) {
			GUI_Utilities.busy_cursor(true, this);
			try {
				data_builder.send_market_data_request(tradable,
					current_period_type);
				if (request_result_id() == OK) {
					// Ensure that the indicator list is up-to-date with
					// respect to `tradable'.
					data_builder.send_indicator_list_request(tradable,
						current_period_type);
					// Force call to `indicators()' to create new indicator
					// lists with the result of the above request.
					new_indicators = true;
					indicators();
				} else {
					// Handle request error.
					if (request_result_id() == Invalid_symbol) {
						handle_nonexistent_sybmol(tradable);
					} else if (request_result_id() == Invalid_period_type) {
						handle_invalid_period_type(tradable);
					} else if (request_result_id() == Warning ||
							request_result_id() == Error) {
						new ErrorBox("Warning",
							"Error occurred retrieving " +
							"data for " + tradable, this_chart);
					}
					GUI_Utilities.busy_cursor(false, this);
					return;
				}
			}
			catch (Exception e) {
				fatal("Request to server failed: ", e);
			}
			//Ensure that all graph's data sets are removed.  (May need to
			//change later.)
			main_pane.clear_main_graph();
			main_pane.clear_indicator_graph();
			main_dataset = data_builder.last_market_data();
			link_with_axis(main_dataset, null);
			main_pane.add_main_data_set(main_dataset);
			if (! current_upper_indicators.isEmpty()) {
				// Retrieve the data for the newly requested tradable for
				// the upper indicators, add it to the upper graph and
				// draw the new indicator data and the tradable data.
				count = current_upper_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_upper_indicators.elementAt(i);
					try {
						data_builder.send_indicator_data_request(((Integer)
							indicators().get(current_indicator)).
								intValue(), tradable, current_period_type);
					} catch (Exception e) {
						fatal("Exception occurred", e);
					}
					dataset = data_builder.last_indicator_data();
					dataset.set_dates_needed(false);
					dataset.set_color(
						conf.indicator_color(current_indicator, true));
					link_with_axis(dataset, current_indicator);
					main_pane.add_main_data_set(dataset);
				}
			}
			current_tradable = tradable;
			set_window_title();
			if (! current_lower_indicators.isEmpty()) {
				// Retrieve the indicator data for the newly requested
				// tradable for the lower indicators and draw it.
				count = current_lower_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_lower_indicators.elementAt(i);
					if (current_lower_indicators.elementAt(i).equals(
							Volume)) {
						// (Nothing to retrieve from server)
						dataset = data_builder.last_volume();
					} else if (current_lower_indicators.elementAt(i).equals(
							Open_interest)) {
						// (Nothing to retrieve from server)
						dataset = data_builder.last_open_interest();
					} else {
						try {
							data_builder.send_indicator_data_request(
								((Integer) indicators().get(
									current_indicator)).intValue(),
									tradable, current_period_type);
						} catch (Exception e) {
							fatal("Exception occurred", e);
						}
						dataset = data_builder.last_indicator_data();
					}
					if (dataset != null) {
						dataset.set_color(conf.indicator_color(
							current_indicator, false));
						link_with_axis(dataset, current_indicator);
						add_indicator_lines(dataset, current_indicator);
						main_pane.add_indicator_data_set(dataset);
					}
				}
			}
			main_pane.repaint_graphs();
			GUI_Utilities.busy_cursor(false, this);
			period_type_change = false;
		}
	}

// Implementation

	// Add any extra lines to the indicator graph - specified in the
	// configuration.
	protected void add_indicator_lines(DataSet dataset, String indicator) {
		if (current_lower_indicators.isEmpty()) {
			return;
		}

		Vector lines;
		double d1, d2;
		MA_Configuration conf = MA_Configuration.application_instance();
		lines = conf.vertical_indicator_lines_at(indicator);
		if (lines != null && lines.size() > 0) {
			for (int j = 0; j < lines.size(); j += 2) {
				d1 = ((Float) lines.elementAt(j)).floatValue();
				d2 = ((Float) lines.elementAt(j+1)).floatValue();
				dataset.add_vline(new DoublePair(d1, d2));
			}
		}
		lines = conf.horizontal_indicator_lines_at(indicator);
		if (lines != null && lines.size() > 0) {
			for (int j = 0; j < lines.size(); j += 2) {
				d1 = ((Float) lines.elementAt(j)).floatValue();
				d2 = ((Float) lines.elementAt(j+1)).floatValue();
				dataset.add_hline(new DoublePair(d1, d2));
			}
		}
	}

	// Initialize components and obtain and display data for `symbol' if
	// it is not null, etc.
	private void initialize_GUI_components(String symbol) {
		// Create the main scroll pane, size it, and center it.
		main_pane = new MA_ScrollPane(_period_types,
			MA_ScrollPane.SCROLLBARS_NEVER, this, window_settings != null?
				window_settings.print_properties(): null);
		if (window_settings != null && window_count == 1) {
			main_pane.setSize(window_settings.size().width,
				window_settings.size().height + 2);
			setLocation(window_settings.location());
			current_upper_indicators = window_settings.upper_indicators();
			current_lower_indicators = window_settings.lower_indicators();
			replace_indicators = window_settings.replace_indicators();
		} else {
			main_pane.setSize(800, 460);
			current_upper_indicators = new Vector();
			current_lower_indicators = new Vector();
		}
		add(main_pane, "Center");
		if (symbol != null) {
			if (options_.print_on_startup() &&
					window_count == 1) {
				print_all_charts();
			}
			// Show the graph of the first symbol in the selection list.
			send_data_request(symbol);
		}
		market_selections = new MarketSelection(this);
		ma_menu_bar = new MA_MenuBar(this, data_builder, _period_types);
		setMenuBar(ma_menu_bar);

		// Event listener for close requests
		addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { close(); }
		});

		pack();
		show();
	}

	// Set the window title using current_tradable and current_lower_indicators.
	protected void set_window_title() {
		if (! current_lower_indicators.isEmpty()) {
			StringBuffer newtitle = new
				StringBuffer (current_tradable.toUpperCase() + " - ");
			int i;
			for (i = 0; i < current_lower_indicators.size() - 1; ++i) {
				newtitle.append(current_lower_indicators.elementAt(i));
				newtitle.append(", ");
			}
			newtitle.append(current_lower_indicators.elementAt(i));
			setTitle(newtitle.toString());
		}
		else {
			setTitle(current_tradable.toUpperCase());
		}
	}

	// Notify the user that the symbol chosen does not exist and then
	// remove the symbol from the selection list.
	private void handle_nonexistent_sybmol(String symbol) {
		ErrorBox errorbox = new ErrorBox("",
			"Symbol " + symbol + " is not in the database.", this_chart);
		market_selections.remove_selection(symbol);
	}

	// Notify the user that the symbol chosen does not exist and then
	// remove the symbol from the selection list.
	private void handle_invalid_period_type(String tradable) {
		try {
			_period_types = data_builder.trading_period_type_list(tradable);
			if (_period_types.size() > 0) {
				current_period_type = initial_period_type(_period_types);
				ma_menu_bar.reset_period_types(_period_types);
				send_data_request(tradable);
			} else {
				new ErrorBox("Warning", "No valid period types for " +
					tradable, this_chart);
			}
		} catch (IOException e) {
			System.err.println("IO exception occurred: " + e + " - aborting");
			e.printStackTrace();
			quit(-1);
		}
	}

	// Save persistent settings as a serialized file.
	// Precondition: main_pane != null
	protected void save_settings() {
//		assert main_pane != null: PRECONDITION;
		if (serialize_filename != null) {
			try {
				FileOutputStream chartfile =
					new FileOutputStream(serialize_filename);
				ObjectOutputStream oos = new ObjectOutputStream(chartfile);
				ChartSettings cs = new ChartSettings(main_pane.getSize(),
					main_pane.print_properties, getLocation(),
					current_upper_indicators, current_lower_indicators,
					replace_indicators);
				for (int i = 0; i < saved_dialogs.size(); ++i) {
					Dialog d = (Dialog) saved_dialogs.elementAt(i);
					WindowSettings ws = new WindowSettings(
						d.getSize(), d.getLocation());
					cs.add_window_setting(ws, d.getTitle());
				}
				oos.writeObject(cs);
				oos.flush();
				oos.close();
			}
			catch (IOException e) {
				System.err.println("Could not save file " + serialize_filename);
				System.err.println(e);
			}
		}
	}

	// Set replace_indicators to its opposite state.
	protected void toggle_indicator_replacement() {
		replace_indicators = ! replace_indicators;
	}

	// Add a menu item for each indicator to `imenu'.
	protected void add_indicators(Menu imenu) {
		MenuItem menu_item;
		IndicatorListener listener = new IndicatorListener(this);
		Enumeration ind_keys = ordered_indicator_list.elements();
		for ( ; ind_keys.hasMoreElements(); ) {
			menu_item = new MenuItem((String) ind_keys.nextElement());
			imenu.add(menu_item);
			menu_item.addActionListener(listener);
		}
	}

	// Print the chart for each member of market_selections
	protected void print_all_charts() {
		main_pane.print(true);
	}

	/** Close a window.  If this is the last open window, just quit. */
	protected void close() {
		if (window_count == 1) {	// Close last remaining window, exit.
			save_settings();
			data_builder.logout(true, 0);
			dispose();
		}
		else {		// More than 1 windows remain, close this one.
			--window_count;
			data_builder.logout(false, 0);
			dispose();
		}
	}

	/** Quit gracefully, sending a logout request for each open window. */
	protected void quit(int status) {
		if (main_pane != null) save_settings();
		log_out_and_exit(status);
	}

	/** Log out of all sessions and exit. */
	protected void log_out_and_exit(int status) {
		// Log out the corresponding session for all but one window.
		for (int i = 0; i < window_count - 1; ++i) {
			data_builder.logout(false, 0);
		}
		// Log out the remaining window and exit with `status'.
		data_builder.logout(true, status);
	}

	// Print fatal error and exit after saving settings.
	protected void fatal(String s, Exception e) {
		System.err.println("Fatal error: " + s);
		if (current_tradable != null) {
			System.err.println("Current symbol is " + current_tradable);
		}
		if (e != null) {
			System.err.println("(" + e + ")");
			e.printStackTrace();
		}
		System.err.println("Exiting ...");
		quit(-1);
	}

	// Same as `fatal' except `save_settings' is not called.
	protected void abort(String s, Exception e) {
		System.err.println("Fatal error: " + s);
		if (current_tradable != null) {
			System.err.println("Current symbol is " + current_tradable);
		}
		if (e != null) {
			System.err.println("(" + e + ")");
			e.printStackTrace();
		}
		System.err.println("Exiting ...");
		log_out_and_exit(-1);
		// If still running, ignore-termination flag is on -
		// Display the error message.
		new ErrorBox("Warning", s != null? s: "Error encountered", this_chart);
	}

	// Link `d' with the appropriate indicator group, using `indicator_name'
	// as a key.  If `indicator_name' is null, the group for the main
	// (upper) graph will be used.  If `indicator_name' specifies an
	// indicator that is not a group member, no action is taken.
	protected void link_with_axis(DataSet d, String indicator_name) {
		if (indicator_groups == null) {
			indicator_groups = (IndicatorGroups) MA_Configuration.
				application_instance().indicator_groups().clone();
		}
		MonoAxisIndicatorGroup group;
		if (indicator_name == null) {
			indicator_name = indicator_groups.Maingroup;
		}
		group = (MonoAxisIndicatorGroup) indicator_groups.at(indicator_name);
		if (group != null) {
			group.attach_data_set(d);
		}
	}

	private boolean vector_has(Vector v, String s) {
		return Utilities.vector_has(v, s);
	}

	// First period type to be displayed - daily, if it exists
	String initial_period_type(Vector types) {
		String result = null;
		String daily = MA_MenuBar.daily_period.toLowerCase();
		for (int i = 0; result == null && i < types.size(); ++i) {
			if (((String) types.elementAt(i)).toLowerCase().equals(daily)) {
				result = (String) types.elementAt(i);
			}
		}
		if (result == null) result = (String) types.elementAt(0);

		return result;
	}

	protected DataSetBuilder data_builder;

	private Chart this_chart;

	// # of open windows - so program can exit when last one is closed
	protected static int window_count = 0;

	// Main window pane
	MA_ScrollPane main_pane;

	// The menu bar for this chart
	MA_MenuBar ma_menu_bar;

	// Valid trading period types - static for now, since it is currently
	// hard-coded in the server
	protected static Vector _period_types;	// Vector of String

	// Table of market indicators
	protected static Hashtable _indicators;	// key: String, value: Integer

	// Has data_builder.send_indicator_list_request been called since the
	// last call to `indicators'?
	protected boolean new_indicators = true;

	// Indicators in user-specified order - includes no-upper/lower,
	// volume, and open-interest indicators
	private static Vector ordered_indicator_list;	// Vector of String

	// Current selected tradable
	protected String current_tradable;

	// Current selected period type
	protected String current_period_type;

	// Has the period type just been changed?
	protected boolean period_type_change;

	// Upper indicators currently selected for display
	protected Vector current_upper_indicators;

	// Lower indicators currently selected for display
	protected Vector current_lower_indicators;

	// Should new indicator selections replace, rather than be added to,
	// existing indicators?
	boolean replace_indicators;

	protected MarketSelection market_selections;

	protected final String No_upper_indicator = "No upper indicator";

	protected final String No_lower_indicator = "No lower indicator";

	protected final String Volume = "Volume";

	protected final String Open_interest = "Open interest";

	String serialize_filename;

	static ChartSettings window_settings;

	IndicatorGroups indicator_groups;

	// Dialog windows registered to have their settings saved on exit
	private Vector saved_dialogs;

	// Saved result of data_builder.last_indicator_list(), used by
	// `indicators' to compare old list with new list
	private Vector old_indicators_from_server = null;

	// User-specified options
	StartupOptions options_;

	// Did the previously retrieved data from the server contain an
	// open interest field?
	private boolean previous_open_interest;

	// Is data being requested? - state flag used for threading data requests
	private Boolean requesting_data = Boolean.FALSE;

	// Currently requested tradable - used for threading data requests
	private String requested_tradable;
}
