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

/** Market analysis GUI chart component */
public class Chart extends Frame implements Runnable {
	public Chart(DataSetBuilder builder) {
		super("Chart");		// Create the main window frame.
		num_windows++;			// Count it.
		data_builder = builder;
		this_chart = this;
		Vector inds;

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
		current_period_type = main_pane.current_period_type();
		new Thread(this).start();
	}

	// From parent Runnable - for threading
	public void run() {
		// null method
	}

	// List of all markets in the server's database
	Vector markets() {
		return _markets;
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
		// Don't redraw the data if it's for the same market as before.
		if (period_type_change || ! market.equals(current_market)) {
			GUI_Utilities.busy_cursor(true, this);
			try {
				data_builder.send_market_data_request(market,
					current_period_type);
			}
			catch (Exception e) {
				System.err.println("Exception occurred: "+e+", bye ...");
				e.printStackTrace();
				quit(-1);
			}
			//Ensure that all graph's data sets are removed.  (May need to
			//change later.)
			main_pane.clear_main_graph();
			main_dataset = data_builder.last_market_data();
			main_pane.add_main_data_set(main_dataset);
			if (current_upper_indicator != null &&
					! current_upper_indicator.equals(No_upper_indicator)) {
				// Retrieve the data for the newly selected market for the
				// upper indicator, add it to the upper graph and draw
				// the new indicator data and the market data.
				try {
					data_builder.send_indicator_data_request(
						((Integer) _indicators.get(current_upper_indicator)).
							intValue(), market, current_period_type);
				} catch (Exception e) {
					System.err.println("Exception occurred: "+e+", bye ...");
					e.printStackTrace();
					quit(-1);
				}
				dataset = data_builder.last_indicator_data();
				dataset.set_dates_needed(false);
				dataset.set_y_min_max(main_dataset);
				main_pane.add_main_data_set(dataset);
			}
			current_market = market;
			set_window_title();
			if (current_lower_indicator != null &&
					! current_lower_indicator.equals(No_lower_indicator)) {
				// Retrieve the indicator data for the newly selected market
				// for the lower indicator and draw it.
				main_pane.clear_indicator_graph();
				if (current_lower_indicator.equals(Volume)) {
					// (Nothing to retrieve from server)
					dataset = data_builder.last_volume();
				} else {
					try {
						data_builder.send_indicator_data_request(
						((Integer) _indicators.get(current_lower_indicator)).
								intValue(), market, current_period_type);
					} catch (Exception e) {
						System.err.println(
							"Exception occurred: "+e+", bye ...");
						e.printStackTrace();
						quit(-1);
					}
					dataset = data_builder.last_indicator_data();
				}
				add_indicator_lines(dataset);
				main_pane.add_indicator_data_set(dataset);
			}
			main_pane.repaint_graphs();
			GUI_Utilities.busy_cursor(false, this);
		}
	}

// Implementation

	// Add any extra lines to the indicator graph - specified in the
	// configuration.
	private void add_indicator_lines(DataSet dataset) {
		if (current_lower_indicator == null ||
			current_lower_indicator.equals(No_lower_indicator)) {
			return;
		}
		Vector lines;
		double d1, d2;
		Configuration conf = Configuration.instance();
		lines = conf.vertical_indicator_lines_at(current_lower_indicator);
		if (lines != null && lines.size() > 0) {
			for (int i = 0; i < lines.size(); i += 2) {
				d1 = ((Float) lines.elementAt(i)).floatValue();
				d2 = ((Float) lines.elementAt(i+1)).floatValue();
				dataset.add_vline(new DoublePair(d1, d2));
			}
		}
		lines = conf.horizontal_indicator_lines_at(current_lower_indicator);
		if (lines != null && lines.size() > 0) {
			for (int i = 0; i < lines.size(); i += 2) {
				d1 = ((Float) lines.elementAt(i)).floatValue();
				d2 = ((Float) lines.elementAt(i+1)).floatValue();
				dataset.add_hline(new DoublePair(d1, d2));
			}
		}
	}

	private void initialize_GUI_components() {
		// Create the main scroll pane, size it, and center it.
		main_pane = new MA_ScrollPane(_period_types,
			MA_ScrollPane.SCROLLBARS_NEVER, this);
		main_pane.setSize(800, 460);
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
		MenuItem newwin, closewin, mkt_selection, print_cmd, quit;
		file_menu.add(newwin = new MenuItem("New Window",
							new MenuShortcut(KeyEvent.VK_N)));
		file_menu.add(mkt_selection = new MenuItem("Select Market",
							new MenuShortcut(KeyEvent.VK_S)));
		file_menu.add(closewin = new MenuItem("Close Window",
							new MenuShortcut(KeyEvent.VK_W)));
		file_menu.addSeparator();
		file_menu.add(print_cmd = new MenuItem("Print",
							new MenuShortcut(KeyEvent.VK_P)));
		file_menu.addSeparator();
		file_menu.add(
			quit = new MenuItem("Quit", new MenuShortcut(KeyEvent.VK_Q)));

		// Create and register action listener objects for the three menu items.
		newwin.addActionListener(new ActionListener() {	// Open a new window
		public void actionPerformed(ActionEvent e) {
				new Chart(new DataSetBuilder(data_builder));
			}
		});

		mkt_selection.addActionListener(market_selection);

		closewin.addActionListener(new ActionListener() {// Close this window.
		public void actionPerformed(ActionEvent e) { close(); }
		});

		print_cmd.addActionListener(new ActionListener() {// Print
		public void actionPerformed(ActionEvent e) {
			if (! (current_market == null || current_market.length() == 0)) {
				main_pane.print();
			}
			else { // Let the user know there is currently nothing to print.
				final Dialog dialog = new Dialog(this_chart);
				Button ok_button = new Button("Nothing to print");
				dialog.add(ok_button, "Center"); dialog.setSize(145, 65);
				dialog.setTitle("Printing error"); dialog.show();
				ok_button.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						dialog.setVisible(false); }});
				dialog.addWindowListener(new WindowAdapter() {
					public void windowClosing(WindowEvent e) {
						dialog.setVisible(false); }});
				ok_button.addKeyListener(new KeyAdapter() {
					public void keyPressed(KeyEvent e) {
						dialog.setVisible(false); }});
			}
		}});

		quit.addActionListener(new ActionListener() {     // Quit the program.
		public void actionPerformed(ActionEvent e) { quit(0); }
		});

		// Another event listener, this one to handle window close requests.
		this.addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { close(); }
		});

		// Set the window size and pop it up.
		setSize(800, 460);
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
		//!!Note: When you get there, the listener(s) that is used to
		//process events for the above menu items can probably use the
		//menu item name, which will be the indicator name, as a key
		//in a hash table that will give the "indicator ID".  The menu
		//item name will be available from the getActionCommand
		//method of the ActionEvent argument to ActionListener's
		//actionPerformed method.  This will probably be set here.
	}

	/** Close a window.  If this is the last open window, just quit. */
	private void close() {
		if (--num_windows == 0) {
			data_builder.logout(true, 0);
		}
		else {
			data_builder.logout(false, 0);
			this.dispose();
		}
	}

	/** Quit gracefully, sending a logout request for each open window. */
	private void quit(int status) {
		// Log out the corresponding session for all but one window.
		for (int i = 0; i < num_windows - 1; ++i) {
			data_builder.logout(false, 0);
		}
		// Log out the remaining window and exit with `status'.
		data_builder.logout(true, status);
	}

	// Set the window title using current_market and current_lower_indicator.
	private void set_window_title() {
		if (current_lower_indicator != null &&
				! current_lower_indicator.equals(No_lower_indicator)) {
			setTitle(current_market.toUpperCase() + " - " +
				current_lower_indicator);
		}
		else {
			setTitle(current_market.toUpperCase());
		}
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

	protected static Vector _markets;		// Vector of String

	// Cached list of market indicators
	protected static Hashtable _indicators;	// table of String

	// Current selected market
	protected String current_market;

	// Current selected period type
	protected String current_period_type;

	// Has the period type just been changed?
	protected boolean period_type_change;

	// Current selected market
	protected String current_upper_indicator;

	// Current selected market
	protected String current_lower_indicator;

	protected MarketSelection market_selection;

	protected final String No_upper_indicator = "No upper indicator";

	protected final String No_lower_indicator = "No lower indicator";

	protected final String Volume = "Volume";

/** Listener for indicator selection */
class IndicatorListener implements java.awt.event.ActionListener {
	public void actionPerformed(java.awt.event.ActionEvent e) {
		String selection = e.getActionCommand();
		DataSet dataset, main_dataset;
		try {
			String market = current_market;
			if (market == null || selection.equals(current_upper_indicator) ||
				selection.equals(current_lower_indicator)) {
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
			if (current_upper_indicator != null) {
				// Remove the old indicator data from the graph (and the
				// market data).
				main_pane.clear_main_graph();
				// Re-attach the market data.
				main_pane.add_main_data_set(main_dataset);
			}
			current_upper_indicator = selection;
			dataset = data_builder.last_indicator_data();
			dataset.set_dates_needed(false);
			dataset.set_y_min_max(main_dataset);
			main_pane.add_main_data_set(dataset);
		}
		else if (selection.equals(No_upper_indicator)) {
			// Remove the old indicator and market data from the graph.
			main_pane.clear_main_graph();
			// Re-attach the market data without the indicator data.
			main_pane.add_main_data_set(data_builder.last_market_data());
			current_upper_indicator = selection;
		}
		else if (selection.equals(No_lower_indicator)) {
			main_pane.clear_indicator_graph();
			current_lower_indicator = selection;
			set_window_title();
		}
		else {
			main_pane.clear_indicator_graph();
			current_lower_indicator = selection;
			set_window_title();
			if (selection.equals(Volume)) {
				dataset = data_builder.last_volume();
			} else {
				dataset = data_builder.last_indicator_data();
			}
			add_indicator_lines(dataset);
			main_pane.add_indicator_data_set(dataset);
		}
		main_pane.repaint_graphs();
	}
}
}
