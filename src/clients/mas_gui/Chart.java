/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import java.io.*;
import support.*;
import common.*;
import java_library.support.*;
import application_support.*;
import application_library.*;
import graph_library.DataSet;
import graph.*;

/** Market analysis GUI chart component */
public class Chart extends Frame implements Runnable, NetworkProtocol,
	ChartInterface, ChartConstants, AssertionConstants,
	TimeDelimitedDataRequestClient {

// Initialization

	public Chart(DataSetBuilder builder, String sfname, StartupOptions opt) {
		super("Chart");
		++window_count;
		options = opt;
		this_chart = this;
		Vector tradables = null;
		saved_dialogs = new Vector();
		data_manager = new ChartDataManager(builder, this);

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
		String s = null;
		tradables = data_manager.tradables();
		if (tradables != null && tradables.size() > 0) {
			s = (String) tradables.elementAt(0);
		}
		initialize_GUI_components(s);
		post_initialize();
	}

// Access

	/**
	* Startup options
	**/
	public StartupOptions options() {
		return options;
	}

	/**
	* Result of last request to the server
	**/
	public int request_result_id() {
		return data_manager.request_result_id();
	}

	/**
	* Symbol for current selected tradable
	**/
	public String current_tradable() {
		return data_manager.current_tradable();
	}

	/**
	* Current selected period_type
	**/
	public String current_period_type() {
		return data_manager.current_period_type();
	}

	/**
	* Valid trading period types for the current tradable
	**/
	public Vector period_types() {
		return data_manager.period_types();
	}

// Access - TimeDelimitedDataRequestClient API

	public Calendar start_date() {
		Calendar result = data_manager.latest_date_time();
		return result;
	}

	public Calendar end_date() {
		// null represents "now".
		return null;
	}

	public ChartableSpecification specification() {
		return data_manager.specification();
	}

	public AbstractDataSetBuilder data_builder() {
		return data_manager.data_builder();
	}

// Status report - TimeDelimitedDataRequestClient API

	public boolean is_exiting() { return is_exiting; }

// Element change

	// Update the period-types menu to synchronize with `period_types'.
	public void reset_period_types_menu() {
		ma_menu_bar.reset_period_types(period_types());
	}

// Basic operations

	public void send_period_types_request(String tradable) {
		data_manager.send_period_types_request(tradable);
	}

	public void send_data_request(String tradable) {
		data_manager.send_data_request(tradable);
	}

	public void reinitialize_current_period_type() {
		data_manager.reinitialize_current_period_type();
	}

	public Vector tradables() {
		return data_manager.tradables();
	}

	public Vector ordered_indicators() {
		return data_manager.ordered_indicators();
	}

	public Vector current_upper_indicators() {
		return data_manager.current_upper_indicators();
	}

	public int indicator_id_for(String name) {
		return data_manager.indicator_id_for(name);
	}

	// Display the specified warning message.
	public void display_warning(String msg) {
		new ErrorBox("Warning", msg, this_chart);
	}

	/** Log out of all sessions and exit. */
	public void log_out_and_exit(int status) {
		MA_Configuration conf = MA_Configuration.application_instance();
		Iterator charts = conf.active_charts();
		while (charts.hasNext()) {
			Chart c = (Chart) charts.next();
			if (c != this) {
				c.close();
			}
		}
		this.close();
	}

	/** Quit gracefully, sending a logout request for each open window. */
	public void quit(int status) {
		if (main_pane != null) {
			save_settings();
		}
		log_out_and_exit(status);
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

// Basic operations - TimeDelimitedDataRequestClient API

	public void update_start_date(AbstractDataSetBuilder b) {
		data_manager.update_latest_date_time(b.last_latest_date_time());
	}

	public void notify_of_update() {
		redraw_graphs();
	}

	// Report a failure and then logout and abort.
	public void notify_of_failure(Exception e) {
		ErrorBox eb = new ErrorBox("Warning", "data request to server failed " +
			"[Trace information: " + e + "]", this_chart);
		eb.setModal(true);
		//@@@Need to change such that the process exits when `eb' is closed.
		fatal("Data request to server failed", e);
	}

	public void notify_of_error(int result_id, String msg) {
		display_warning("data request failed with code: " + result_id +
			", " + msg);
	}

// Package-level access

	ChartDataManager data_manager() {
		return data_manager;
	}

	MarketSelection tradable_selections() {
		return tradable_selections;
	}

	// Main window pane
	MA_ScrollPane main_pane() {
		return main_pane;
	}

	// Force all graphs contained in the chart window to be redrawn.
	void redraw_graphs() {
		main_pane.force_repaint_graphs();
	}

	// Set the window title using current_tradable() and
	// the current lower indicators.
	void set_window_title() {
		Vector lower_indicators = data_manager.current_lower_indicators();
		if (! lower_indicators.isEmpty()) {
			StringBuffer newtitle = new
				StringBuffer (current_tradable().toUpperCase() + " - ");
			int i;
			for (i = 0; i < lower_indicators.size() - 1; ++i) {
				newtitle.append(lower_indicators.elementAt(i));
				newtitle.append(", ");
			}
			newtitle.append(lower_indicators.elementAt(i));
			setTitle(newtitle.toString());
		}
		else {
			setTitle(current_tradable().toUpperCase());
		}
	}

	// Turn on 'auto data refresh'.
	// Ignore if auto_refresh_handler == null
	void turn_on_refresh() {
		if (auto_refresh_handler != null) {
			auto_refresh_handler.schedule();
		}
	}

	// Turn off 'auto data refresh'.
	// Ignore if auto_refresh_handler == null
	void turn_off_refresh() {
		if (auto_refresh_handler != null) {
			auto_refresh_handler.unschedule();
		}
	}

	// Take action when notified that period type changed.
	void notify_period_type_changed(String new_period_type) {
		data_manager.notify_period_type_changed(new_period_type);
	}

	// Request data for the specified tradable and display it, using
	// a thread for efficiency.
	void request_data(String tradable) {
		requested_tradable = tradable;
		new Thread(this).start();
	}

	// Set replace_indicators to its opposite state.
	void toggle_indicator_replacement() {
		data_manager.toggle_indicator_replacement();
	}

	boolean replace_indicators() {
		return data_manager.replace_indicators();
	}

	String serialize_filename() {
		return serialize_filename;
	}

	// Add any extra lines to the indicator graph - specified in the
	// configuration.
	void add_indicator_lines(DrawableDataSet dataset,
			String indicator) {

		if (data_manager.current_lower_indicators().isEmpty()) {
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

	// Update indicator lists in GUI components that use them.
	void update_indicators() {
		if (ma_menu_bar != null) {
			ma_menu_bar.update_indicators();
		}
	}

	// Notify the user that the symbol chosen does not exist and then
	// remove the symbol from the selection list.
	void handle_nonexistent_sybmol(String symbol) {
		display_warning("Symbol " + symbol + " is not in the database.");
		tradable_selections.remove_selection(symbol);
	}

	/**
	* Print fatal error and exit after saving settings.
	**/
	void fatal(String s, Exception e) {
		data_manager.facilities().fatal(s, e);
	}

	/**
	* Settings for dialog with title `s'
	**/
	WindowSettings settings_for(String s) {
		WindowSettings result = null;
		if (window_settings != null) {
			result = window_settings.wsettings(s);
		}
		return result;
	}

	/**
	* Register `d' to save its size and location on exit with its title
	* as a key.
	**/
	void register_dialog_for_save_settings(Dialog d) {
		saved_dialogs.addElement(d);
	}

	// Save persistent settings as a serialized file.
	// Precondition: main_pane != null
	void save_settings() {
		assert main_pane != null: PRECONDITION;
		if (serialize_filename != null) {
			try {
				FileOutputStream chartfile =
					new FileOutputStream(serialize_filename);
				ObjectOutputStream oos = new ObjectOutputStream(chartfile);
				ChartSettings cs = new ChartSettings(main_pane.getSize(),
					main_pane.print_properties, getLocation(),
					data_manager.current_upper_indicators(),
					data_manager.current_lower_indicators(),
					data_manager.replace_indicators());
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

// Implementation

	// Initialize components and obtain and display data for `symbol' if
	// it is not null, etc.
	private void initialize_GUI_components(String symbol) {
		// Create the main scroll pane, size it, and center it.
		main_pane = new MA_ScrollPane(period_types(),
			MA_ScrollPane.SCROLLBARS_NEVER, this, window_settings != null?
				window_settings.print_properties(): null);
		if (window_settings != null && window_count == 1) {
			main_pane.setSize(window_settings.size().width,
				window_settings.size().height + 2);
			setLocation(window_settings.location());
			data_manager.set_current_upper_indicators(
				window_settings.upper_indicators());
			data_manager.set_current_lower_indicators(
				window_settings.lower_indicators());
			data_manager.set_replace_indicators(
				window_settings.replace_indicators());
		} else {
			main_pane.setSize(800, 460);
		}
		add(main_pane, "Center");
		if (symbol != null) {
			if (options.print_on_startup() &&
					window_count == 1) {
				print_all_charts();
			}
			// Show the graph of the first symbol in the selection list.
			send_data_request(symbol);
		}
		tradable_selections = new MarketSelection(this);
		try {
			ma_menu_bar = new MA_MenuBar(this,
				(DataSetBuilder) data_manager.data_builder(), period_types());
		} catch (Exception e) {
			notify_of_failure(e);
		}
		setMenuBar(ma_menu_bar);

		// Event listener for close requests
		addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { close(); }
		});

		pack();
		show();
	}

	// Perform any other needed initialization after
	// `initialize_GUI_components' has been called.
	private void post_initialize() {
		MA_Configuration conf = MA_Configuration.application_instance();
		conf.add_chart(this);
		if (conf.auto_refresh()) {
			auto_refresh_handler = new AutoRefreshSetup(this);
			turn_on_refresh();
		}
	}

	// Add a menu item for each indicator to `imenu'.
	protected void add_indicators(Menu imenu) {
		MenuItem menu_item;
		IndicatorListener listener = new IndicatorListener(this);
		Iterator ind_keys = data_manager.ordered_indicators().iterator();
		while (ind_keys.hasNext()) {
			menu_item = new MenuItem((String) ind_keys.next());
			imenu.add(menu_item);
			menu_item.addActionListener(listener);
		}
	}

	// Print the chart for each member of tradable_selections
	protected void print_all_charts() {
		main_pane.print(true);
	}

	/**
	* Close this chart window.
	* If this is the last open window, terminate the process. */
	protected void close() {
		turn_off_refresh();
		if (window_count == 1) {	// Close last remaining window, exit.
			save_settings();
			data_manager.data_builder().logout(true, 0);
			dispose();
		}
		else {		// More than 1 windows remain, close this one.
			--window_count;
			data_manager.data_builder().logout(false, 0);
			dispose();
		}
	}


// Implementation - attributes

	private Chart this_chart;

	// # of open windows - so program can exit when last one is closed
	protected static int window_count = 0;

	// Main window pane
	private MA_ScrollPane main_pane;

	// The menu bar for this chart
	private MA_MenuBar ma_menu_bar;

	private MarketSelection tradable_selections;

	private String serialize_filename;

	private static ChartSettings window_settings;

	// Dialog windows registered to have their settings saved on exit
	private Vector saved_dialogs;

	// User-specified options
	private StartupOptions options;

	// Is data being requested? - state flag used for threading data requests
	private Boolean requesting_data = Boolean.FALSE;

	// Currently requested tradable - used for threading data requests
	private String requested_tradable;

	private static NetworkProtocolUtilities protocol_util =
		new NetworkProtocolUtilities();

	private AutoRefreshSetup auto_refresh_handler;

	private ChartDataManager data_manager;

	private static boolean is_exiting = false;
}
