// The windowing and event registration code in this class is adapted from
// "Java in a Nutshell, Second Edition", by David Flanagan.  [Copyright (c)
// 1997 O'Reilly & Associates.]  The license for that code says:
// "You may distribute this source code for non-commercial purposes only.
// You may study, modify, and use this example for any purpose, as long as
// this notice is retained.  Note that this example is provided "as is",
// WITHOUT WARRANTY of any kind either expressed or implied."

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

class ChartSettings implements Serializable {
	public ChartSettings(Dimension sz, Properties printprop, Point loc,
			Vector upperind, Vector lowerind, boolean replace_ind) {
		size_ = sz;
		print_properties_ = printprop;
		location_ = loc;
		upper_indicators_ = upperind;
		lower_indicators_ = lowerind;
		replace_indicators_ = replace_ind;
	}
	public Dimension size() { return size_; }
	public Point location() { return location_; }
	public Properties print_properties() { return print_properties_; }
	public Vector upper_indicators() { return upper_indicators_;}
	public Vector lower_indicators() { return lower_indicators_;}
	public boolean replace_indicators() { return replace_indicators_; }

	private Dimension size_;
	private Properties print_properties_;
	private Point location_;
	private Vector upper_indicators_;
	private Vector lower_indicators_;
	private boolean replace_indicators_;
}

/** Market analysis GUI chart component */
public class Chart extends Frame implements Runnable, NetworkProtocol {
	public Chart(DataSetBuilder builder, String sfname) {
		super("Chart");		// Create the main window frame.
		num_windows++;			// Count it.
		data_builder = builder;
		this_chart = this;
		Vector inds;
		Vector _markets = null;

		if (sfname != null) serialize_filename = sfname;

		if (num_windows == 1) {
			ChartSettings settings;
			try {
				FileInputStream chartfile =
					new FileInputStream(serialize_filename);
				ObjectInputStream ios = new ObjectInputStream(chartfile);
				settings = (ChartSettings) ios.readObject();
				window_settings = settings;
			}
			catch (IOException e) {
				System.err.println("Could not read file " +
					serialize_filename);
			}
			catch (ClassNotFoundException e) {
				System.err.println("Class not found!");
			}
		}
		try {
			if (_markets == null) {
				_markets = data_builder.market_list();
				if (! _markets.isEmpty()) {
					// Each market has its own period type list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					_period_types = data_builder.trading_period_type_list(
						(String) _markets.elementAt(0));
					GUI_Utilities.busy_cursor(true, this);
					// Each market has its own indicator list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					data_builder.send_indicator_list_request(
						(String) _markets.elementAt(0));
					if (request_result() == Invalid_symbol) {
						System.err.println("Symbol " + (String)
							_markets.elementAt(0) + " is not in database.");
						System.err.println("Exiting ...");
						System.exit(-1);
					}
					GUI_Utilities.busy_cursor(false, this);
					inds = data_builder.last_indicator_list();
					_indicators = new Hashtable(inds.size());
					int i;
					// Initialize _indicators table with each indicator name
					// in the list, associating each indicator name with its
					// respective index in the list (starting at 1).
					for (i = 0; i < inds.size(); ++i) {
						_indicators.put(inds.elementAt(i), new Integer(i + 1));
					}
					_indicators.put(No_upper_indicator, new Integer(i + 1));
					_indicators.put(No_lower_indicator, new Integer(i + 2));
					_indicators.put(Volume, new Integer(i + 3));
				}
			}
		}
		catch (IOException e) {
			System.err.println("IO exception occurred, bye ...");
			quit(-1);
		}
		initialize_GUI_components();
replace_indicators = false;
		current_period_type = main_pane.current_period_type();
		if (_markets.size() > 0) {
			if (data_builder.options().print_on_startup() && num_windows == 1) {
				print_all_charts();
			}
			// Show the graph of the first symbol in the selection list.
			request_data((String) _markets.elementAt(0));
		}
System.out.println("replace_indicators: " + replace_indicators);
		new Thread(this).start();
	}

	// From parent Runnable - for threading
	public void run() {
		// null method
	}

	// List of all markets in the server's database
	Vector markets() {
		Vector result = null;
		try {
			result = data_builder.market_list();
		}
		catch (IOException e) {
			System.err.println("IO exception occurred, bye ...");
			quit(-1);
		}
		return result;
	}

	// Result of last request to the server
	public int request_result() {
		return data_builder.request_result();
	}

	// Take action when notified that period type changed.
	void notify_period_type_changed() {
		current_period_type = main_pane.current_period_type();
		period_type_change = true;
		if (current_market != null) {
			request_data(current_market);
		}
		period_type_change = false;
	}

	// Request data for the specified market and display it.
	void request_data(String market) {
		DataSet dataset, main_dataset;
		int count;
		String current_indicator;
		// Don't redraw the data if it's for the same market as before.
		if (period_type_change || ! market.equals(current_market)) {
			GUI_Utilities.busy_cursor(true, this);
			try {
				data_builder.send_market_data_request(market,
					current_period_type);
				if (request_result() == Invalid_symbol) {
					handle_nonexistent_sybmol(market);
					GUI_Utilities.busy_cursor(false, this);
					return;
				}
			}
			catch (Exception e) {
				fatal("Request to server failed", e);
			}
			//Ensure that all graph's data sets are removed.  (May need to
			//change later.)
			main_pane.clear_main_graph();
			main_dataset = data_builder.last_market_data();
			link_with_axis(main_dataset, null);
			main_pane.add_main_data_set(main_dataset);
			if (! current_upper_indicators.isEmpty()) {
				// Retrieve the data for the newly requested market for the
				// upper indicator, add it to the upper graph and draw
				// the new indicator data and the market data.
				count = current_upper_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_upper_indicators.elementAt(i);
					try {
						data_builder.send_indicator_data_request(((Integer)
							_indicators.get(current_indicator)).
								intValue(), market, current_period_type);
					} catch (Exception e) {
						System.err.println("Exception occurred: " + e +
							" - Exiting ...");
						e.printStackTrace();
						quit(-1);
					}
					dataset = data_builder.last_indicator_data();
					dataset.set_dates_needed(false);
					link_with_axis(dataset, current_indicator);
					main_pane.add_main_data_set(dataset);
				}
			}
			current_market = market;
			set_window_title();
			if (! current_lower_indicators.isEmpty()) {
				// Retrieve the indicator data for the newly requested market
				// for the lower indicator and draw it.
				main_pane.clear_indicator_graph();
				count = current_lower_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_lower_indicators.elementAt(i);
					if (current_lower_indicators.elementAt(i).equals(Volume)) {
						// (Nothing to retrieve from server)
						dataset = data_builder.last_volume();
					} else {
						try {
						data_builder.send_indicator_data_request(((Integer)
							_indicators.get(current_indicator)).
								intValue(), market, current_period_type);
						} catch (Exception e) {
						System.err.println(
							"Exception occurred: " + e + "- Exiting ...");
						e.printStackTrace();
						quit(-1);
						}
						dataset = data_builder.last_indicator_data();
					}
					link_with_axis(dataset, current_indicator);
					add_indicator_lines(dataset, current_indicator);
					main_pane.add_indicator_data_set(dataset);
				}
			}
			main_pane.repaint_graphs();
			GUI_Utilities.busy_cursor(false, this);
		}
	}

// Implementation

	// Add any extra lines to the indicator graph - specified in the
	// configuration.
	private void add_indicator_lines(DataSet dataset, String indicator) {
		if (current_lower_indicators.isEmpty()) {
			return;
		}

		Vector lines;
		double d1, d2;
		Configuration conf = Configuration.instance();
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

	private void initialize_GUI_components() {
		// Create the main scroll pane, size it, and center it.
		main_pane = new MA_ScrollPane(_period_types,
			MA_ScrollPane.SCROLLBARS_NEVER, this, window_settings != null?
				window_settings.print_properties(): null);
		if (window_settings != null && num_windows == 1) {
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
		market_selection = new MarketSelection(this);

		// Make a menu bar with a file menu.
		MenuBar menubar = new MenuBar();
		setMenuBar(menubar);
		Menu file_menu = new Menu("File");
		Menu indicator_menu = new Menu("Indicators");
		menubar.add(file_menu);
		menubar.add(indicator_menu);
		add_indicators(indicator_menu);

		// Create three menu items, with menu shortcuts, and add to the menu.
		MenuItem newwin, closewin, mkt_selection, print_cmd, print_all, quit;
		file_menu.add(newwin = new MenuItem("New Window",
							new MenuShortcut(KeyEvent.VK_N)));
		file_menu.add(mkt_selection = new MenuItem("Select Market",
							new MenuShortcut(KeyEvent.VK_S)));
		file_menu.add(closewin = new MenuItem("Close Window",
							new MenuShortcut(KeyEvent.VK_W)));
		file_menu.addSeparator();
		file_menu.add(print_cmd = new MenuItem("Print",
							new MenuShortcut(KeyEvent.VK_P)));
		file_menu.add(print_all = new MenuItem("Print all",
							new MenuShortcut(KeyEvent.VK_A)));
		file_menu.addSeparator();
		file_menu.add(
			quit = new MenuItem("Quit", new MenuShortcut(KeyEvent.VK_Q)));

		// Create and register action listener objects for the three menu items.
		newwin.addActionListener(new ActionListener() {	// Open a new window
		public void actionPerformed(ActionEvent e) {
				Chart chart = new Chart(new DataSetBuilder(data_builder), null);
				//chart.setSize(800, 460);
			}
		});

		mkt_selection.addActionListener(market_selection);

		closewin.addActionListener(new ActionListener() {// Close this window.
		public void actionPerformed(ActionEvent e) { close(); }
		});

		print_cmd.addActionListener(new ActionListener() {// Print
		public void actionPerformed(ActionEvent e) {
			if (! (current_market == null || current_market.length() == 0)) {
				main_pane.print(false);
			}
			else { // Let the user know there is currently nothing to print.
				final ErrorBox errorbox = new ErrorBox("Printing error",
					"Nothing to print", this_chart);
			}
		}});

		print_all.addActionListener(new ActionListener() {// Print all
		public void actionPerformed(ActionEvent e) {
			if (! (current_market == null || current_market.length() == 0)) {
				String original_market = current_market;
				print_all_charts();
				request_data((String) original_market);
			}
			else { // Let the user know there is currently nothing to print.
				final ErrorBox errorbox = new ErrorBox("Printing error",
					"Nothing to print", this_chart);
			}
		}});

		quit.addActionListener(new ActionListener() {     // Quit the program.
		public void actionPerformed(ActionEvent e) { quit(0); }
		});

		// Another event listener, this one to handle window close requests.
		this.addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { close(); }
		});

		// Pop up the window.
		pack();
		show();
	}

	// Add a menu item for each indicator to `imenu'.
	private void add_indicators(Menu imenu) {
		MenuItem menu_item;
		IndicatorListener listener = new IndicatorListener();
		Enumeration ind_keys = _indicators.keys();
		for ( ; ind_keys.hasMoreElements(); ) {
			menu_item = new MenuItem((String) ind_keys.nextElement());
			imenu.add(menu_item);
			menu_item.addActionListener(listener);
		}
	}

	/** Close a window.  If this is the last open window, just quit. */
	private void close() {
		if (--num_windows == 0) {
			save_settings();
			data_builder.logout(true, 0);
		}
		else {
			data_builder.logout(false, 0);
			this.dispose();
		}
	}

	/** Quit gracefully, sending a logout request for each open window. */
	private void quit(int status) {
		save_settings();
		// Log out the corresponding session for all but one window.
		for (int i = 0; i < num_windows - 1; ++i) {
			data_builder.logout(false, 0);
		}
		// Log out the remaining window and exit with `status'.
		data_builder.logout(true, status);
	}

	// Set the window title using current_market and current_lower_indicators.
	private void set_window_title() {
		if (! current_lower_indicators.isEmpty()) {
			StringBuffer newtitle = new
				StringBuffer (current_market.toUpperCase() + " - ");
			int i;
			for (i = 0; i < current_lower_indicators.size() - 1; ++i) {
				newtitle.append(current_lower_indicators.elementAt(i));
				newtitle.append(", ");
			}
			newtitle.append(current_lower_indicators.elementAt(i));
			setTitle(newtitle.toString());
		}
		else {
			setTitle(current_market.toUpperCase());
		}
	}

	// Notify the user that the symbol chosen does not exist and then
	// remove the symbol from the selection list.
	private void handle_nonexistent_sybmol(String symbol) {
		ErrorBox errorbox = new ErrorBox("",
			"Symbol " + symbol + " is not in the database.", this_chart);
		market_selection.remove_selection(symbol);
	}

	// Save persistent settings as a serialized file.
	private void save_settings() {
		if (serialize_filename != null) {
		try {
			FileOutputStream chartfile =
				new FileOutputStream(serialize_filename);
			ObjectOutputStream oos = new ObjectOutputStream(chartfile);
			ChartSettings cs = new ChartSettings(main_pane.getSize(),
				main_pane.print_properties, getLocation(),
				current_upper_indicators, current_lower_indicators,
				replace_indicators);
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

	// Link `d' with the appropriate indicator group, using `indicator_name'
	// as a key.  If `indicator_name' is null, the group for the main
	// (upper) graph will be used.  If `indicator_name' specifies an
	// indicator that is not a group member, no action is taken.
	private void link_with_axis(DataSet d, String indicator_name) {
		if (indicator_groups == null) {
			indicator_groups = (IndicatorGroups)
				Configuration.instance().indicator_groups().clone();
		}
		IndicatorGroup group;
		if (indicator_name == null) {
			indicator_name = indicator_groups.Maingroup;
		}
		group = indicator_groups.at(indicator_name);
		if (group != null) {
			group.attach_data_set(d);
		}
	}

	// Print the chart for each member of market_selection
	private void print_all_charts() {
		main_pane.print(true);
	}

	// Print fatal error and exit.
	private void fatal(String s, Exception e) {
		System.err.print("Fatal error: request to server failed. ");
		if (e != null) {
			System.err.println("(" + e + ")");
			e.printStackTrace();
		}
		System.err.println("Exiting ...");
		quit(-1);
	}

	private boolean vector_has(Vector v, String s) {
		return Utilities.vector_has(v, s);
	}

	private DataSetBuilder data_builder;

	private Chart this_chart;

	// # of open windows - so program can exit when last one is closed
	protected static int num_windows = 0;

	// Main window pane
	MA_ScrollPane main_pane;

	// Valid trading period types - static for now, since it is currently
	// hard-coded in the server
	protected static Vector _period_types;	// Vector of String

	// Cached list of market indicators
	protected static Hashtable _indicators;	// table of String

	// Current selected market
	protected String current_market;

	// Current selected period type
	protected String current_period_type;

	// Has the period type just been changed?
	protected boolean period_type_change;

	protected Vector current_upper_indicators;

	protected Vector current_lower_indicators;

	// Should new indicator selections replace, rather than be added to,
	// existing indicators?
	boolean replace_indicators;

	protected MarketSelection market_selection;

	protected final String No_upper_indicator = "No upper indicator";

	protected final String No_lower_indicator = "No lower indicator";

	protected final String Volume = "Volume";

	static String serialize_filename;

	static ChartSettings window_settings;

	IndicatorGroups indicator_groups;

/** Listener for indicator selection */
class IndicatorListener implements
		java.awt.event.ActionListener {
	public void actionPerformed(java.awt.event.ActionEvent e) {
		String selection = e.getActionCommand();
		DataSet dataset, main_dataset;
		try {
			String market = current_market;
			if (market == null ||
				vector_has(current_upper_indicators, selection) ||
				vector_has(current_lower_indicators, selection)) {
				// If no market is selected or the selection hasn't changed,
				// there is nothing to display.
				return;
			}
			if (! (selection.equals(No_upper_indicator) ||
					selection.equals(No_lower_indicator) ||
					selection.equals(Volume))) {
				GUI_Utilities.busy_cursor(true, Chart.this);
				data_builder.send_indicator_data_request(
					((Integer) _indicators.get(selection)).intValue(),
					market, current_period_type);
				GUI_Utilities.busy_cursor(false, Chart.this);
			}
		}
		catch (Exception ex) {
			System.err.println("Exception occurred: " + ex + ", bye ...");
			ex.printStackTrace();
			quit(-1);
		}
		// Set graph data according to whether the selected indicator is
		// configured to go in the upper (main) or lower (indicator) graph.
		if (Configuration.instance().upper_indicators().containsKey(selection))
		{
			main_dataset = data_builder.last_market_data();
			if (! current_upper_indicators.isEmpty() && replace_indicators) {
				// Remove the old indicator data from the graph (and the
				// market data).
				main_pane.clear_main_graph();
				// Re-attach the market data.
				link_with_axis(main_dataset, null);
				main_pane.add_main_data_set(main_dataset);
				current_upper_indicators.removeAllElements();
			}
			current_upper_indicators.addElement(selection);
			dataset = data_builder.last_indicator_data();
			dataset.set_dates_needed(false);
			link_with_axis(dataset, selection);
			main_pane.add_main_data_set(dataset);
		}
		else if (selection.equals(No_upper_indicator)) {
			// Remove the old indicator and market data from the graph.
			main_pane.clear_main_graph();
			// Re-attach the market data without the indicator data.
			link_with_axis(data_builder.last_market_data(), null);
			main_pane.add_main_data_set(data_builder.last_market_data());
			current_upper_indicators.removeAllElements();
		}
		else if (selection.equals(No_lower_indicator)) {
			main_pane.clear_indicator_graph();
			current_lower_indicators.removeAllElements();
			set_window_title();
		}
		else {
			if (selection.equals(Volume)) {
				dataset = data_builder.last_volume();
			} else {
				dataset = data_builder.last_indicator_data();
			}
			if (replace_indicators) {
				main_pane.clear_indicator_graph();
				current_lower_indicators.removeAllElements();
			}
			link_with_axis(dataset, selection);
			current_lower_indicators.addElement(selection);
			set_window_title();
			add_indicator_lines(dataset, selection);
			main_pane.add_indicator_data_set(dataset);
		}
		main_pane.repaint_graphs();
	}
}
}
