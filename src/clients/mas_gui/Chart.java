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
import java.io.*;
import graph.*;
import support.*;

/** Technical analysis GUI chart component */
public class TA_Chart extends Frame {
	public TA_Chart(TA_Connection conn) {
		super("TA_Chart");		// Create the main window frame.
		num_windows++;			// Count it.
		connection = conn;
		Vector inds;

		try {
			session_key = connection.send_login_request();
			if (_markets == null) {
				_markets = connection.market_list(session_key);
				if (! _markets.isEmpty()) {
					// Each market has its own period type list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					_period_types = connection.trading_period_type_list(
						(String) _markets.elementAt(0), session_key);
					// Each market has its own indicator list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					connection.send_indicator_list_request(
						(String) _markets.elementAt(0), session_key);
					inds = connection.last_indicator_list();
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
				}
			}
		}
		catch (IOException e) {
			System.err.println("IO exception occurred, bye ...");
			quit(-1);
		}
		initialize_GUI_components();
		current_period_type = main_pane.current_period_type();
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
		DataSet dataset;
		// Don't redraw the data if it's for the same market as before.
		if (period_type_change || ! market.equals(current_market)) {
			Graph2D graph = main_pane.main_graph();
			try {
				connection.send_market_data_request(market,
					current_period_type, session_key);
			}
			catch (Exception e) {
				System.err.println("Exception occurred: "+e+", bye ...");
				quit(-1);
			}
			//Ensure that all graph's data sets are removed.  (May need to
			//change later.)
			graph.detachDataSets();
			graph.attachDataSet(connection.last_market_data());
			if (current_upper_indicator != null &&
					! current_upper_indicator.equals(No_upper_indicator)) {
				// Retrieve the data for the newly selected market for the
				// upper indicator, add it to the upper graph and draw
				// the new indicator data and the market data.
				try {
					connection.send_indicator_data_request(
						((Integer) _indicators.get(current_upper_indicator)).
							intValue(), market, current_period_type,
							session_key);
				} catch (Exception e) {
					System.err.println("Exception occurred: "+e+", bye ...");
					quit(-1);
				}
				graph.attachDataSet(connection.last_indicator_data());
			}
			graph.repaint();
			setTitle(market);
			current_market = market;
			if (current_lower_indicator != null &&
					! current_lower_indicator.equals(No_lower_indicator)) {
				// Retrieve the indicator data for the newly selected market
				// for the lower indicator and draw it.
				graph = main_pane.indicator_graph();
				graph.detachDataSets();
				try {
					connection.send_indicator_data_request(
						((Integer) _indicators.get(current_lower_indicator)).
							intValue(), market, current_period_type,
							session_key);
				} catch (Exception e) {
					System.err.println("Exception occurred: "+e+", bye ...");
					quit(-1);
				}
				dataset = connection.last_indicator_data();
				add_indicator_lines(dataset);
				graph.attachDataSet(dataset);
				graph.repaint();
			}
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
		main_pane = new TA_ScrollPane(_period_types,
			TA_ScrollPane.SCROLLBARS_NEVER, this);
		main_pane.setSize(610, 410);
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
		MenuItem newwin, closewin, mkt_selection, quit;
		file_menu.add(newwin = new MenuItem("New Window",
							new MenuShortcut(KeyEvent.VK_N)));
		file_menu.add(mkt_selection = new MenuItem("Select Market",
							new MenuShortcut(KeyEvent.VK_S)));
		file_menu.add(closewin = new MenuItem("Close Window",
							new MenuShortcut(KeyEvent.VK_W)));
		file_menu.addSeparator();	// Put a separator in the menu
		file_menu.add(
			quit = new MenuItem("Quit", new MenuShortcut(KeyEvent.VK_Q)));

		// Create and register action listener objects for the three menu items.
		newwin.addActionListener(new ActionListener() {	// Open a new window
		public void actionPerformed(ActionEvent e) { new TA_Chart(connection); }
		});

		mkt_selection.addActionListener(market_selection);

		closewin.addActionListener(new ActionListener() {// Close this window.
		public void actionPerformed(ActionEvent e) { close(); }
		});

		quit.addActionListener(new ActionListener() {     // Quit the program.
		public void actionPerformed(ActionEvent e) { quit(0); }
		});

		// Another event listener, this one to handle window close requests.
		this.addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { close(); }
		});

		// Set the window size and pop it up.
		setSize(610, 410);
		pack();
		show();
	}

	// Add a menu item for each indicator to `imenu'.
	void add_indicators(Menu imenu) {
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
	void close() {
		if (--num_windows == 0) {
			connection.logout(true, 0, session_key);
		}
		else {
			connection.logout(false, 0, session_key);
			this.dispose();
		}
	}

	/** Quit gracefully, sending a logout request for each open window. */
	void quit(int status) {
		// Log out the corresponding session for all but one window.
		for (int i = 0; i < num_windows - 1; ++i) {
			connection.logout(false, 0, session_key);
		}
		// Log out the remaining window and exit with `status'.
		connection.logout(true, status, session_key);
	}

	private TA_Connection connection;

	// # of open windows - so program can exit when last one is closed
	protected static int num_windows = 0;

	// Key for the session associated with this window
	protected int session_key;

	// Main window pane
	TA_ScrollPane main_pane;

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

/** Listener for indicator selection */
class IndicatorListener implements java.awt.event.ActionListener {
	public void actionPerformed(java.awt.event.ActionEvent e) {
		Graph2D graph;
		String selection = e.getActionCommand();
		DataSet dataset;
		try {
			String market = current_market;
			if (market == null || selection.equals(current_upper_indicator) ||
				selection.equals(current_lower_indicator)) {
				// If no market is selected or the selection hasn't changed,
				// there is nothing to display.
				return;
			}
			if (! (selection.equals(No_upper_indicator) ||
					selection.equals(No_lower_indicator))) {
				connection.send_indicator_data_request(
					((Integer) _indicators.get(selection)).intValue(),
					market, current_period_type, session_key);
			}
		}
		catch (Exception ex) {
			System.err.println("Exception occurred: " + ex + ", bye ...");
			quit(-1);
		}
		// Set graph according to whether the selected indicator is
		// configured to go in the upper (main) or lower (indicator) graph.
		if (Configuration.instance().upper_indicators().containsKey(selection))
		{
			graph = main_pane.main_graph();
			if (current_upper_indicator != null) {
				// Remove the old indicator data from the graph (and the
				// market data).
				graph.detachDataSets();
				// Re-attach the market data.
				graph.attachDataSet(connection.last_market_data());
			}
			current_upper_indicator = selection;
			graph.attachDataSet(connection.last_indicator_data());
		}
		else if (selection.equals(No_upper_indicator)) {
			graph = main_pane.main_graph();
			// Remove the old indicator and market data from the graph.
			graph.detachDataSets();
			// Re-attach the market data without the indicator data.
			graph.attachDataSet(connection.last_market_data());
			current_upper_indicator = selection;
		}
		else if (selection.equals(No_lower_indicator)) {
			graph = main_pane.indicator_graph();
			graph.detachDataSets();
			current_lower_indicator = selection;
		}
		else {
			graph = main_pane.indicator_graph();
			graph.detachDataSets();
			current_lower_indicator = selection;
			dataset = connection.last_indicator_data();
			add_indicator_lines(dataset);
			graph.attachDataSet(dataset);
		}
		graph.repaint();
	}
}
}
