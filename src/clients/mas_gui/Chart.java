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
import java.io.*;
import graph.*;

/** Technical analysis GUI chart component */
public class TA_Chart extends Frame
{
	public TA_Chart(TA_Connection conn)
	{
		super("TA_Chart");		// Create the main window frame.
		num_windows++;			// Count it.
		connection = conn;

		try {
			if (_markets == null) {
				_markets = connection.market_list();
				if (! _markets.isEmpty()) {
					// Each market has its own period type list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					_period_types = connection.trading_period_type_list(
						(String) _markets.elementAt(0));
					// Each market has its own indicator list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					connection.send_indicator_list_request(
						(String) _markets.elementAt(0));
					_indicators = connection.last_indicator_list();
				}
			}
		}
		catch (IOException e) {
			System.out.println("IO exception occurred, bye ...");
			System.exit(-1);
		}
		initialize_GUI_components();
	}

	// List of all markets in the server's database
	Vector markets() {
		return _markets;
	}

	// The currently selected period type
	String current_period_type() {
		return main_pane.current_period_type();
	}

	// Take action when notified that period type changed.
	void notify_period_type_changed() {
		request_data(market_selection.current_market());
	}

	// Request data for the specified market and display it.
	void request_data(String market) {
		Graph2D graph = main_pane.main_graph();
		try {
			connection.send_market_data_request(market, current_period_type());
		}
		catch (IOException e2) {
			System.out.println("IO exception occurred, bye ...");
			System.exit(-1);
		}
		//Ensure that all graph's data sets are removed.  (May need to
		//change later.)
		graph.detachDataSets();
		graph.attachDataSet(connection.last_market_data());
		graph.repaint();
		setTitle(market);
	}

// Implementation

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
		MenuItem newwin, closewin, ss, quit;
		file_menu.add(newwin = new MenuItem("New Window",
							new MenuShortcut(KeyEvent.VK_N)));
		file_menu.add(ss = new MenuItem("Select Market",
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

		ss.addActionListener(market_selection);

		closewin.addActionListener(new ActionListener() {// Close this window.
		public void actionPerformed(ActionEvent e) { close(); }
		});

		quit.addActionListener(new ActionListener() {     // Quit the program.
		public void actionPerformed(ActionEvent e) { System.exit(0); }
		});

		// Another event listener, this one to handle window close requests.
		this.addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { close(); }
		});

		// Set the window size and pop it up.
		this.pack();
		this.show();
	}

	// Add a menu item for each indicator to `imenu'.
	void add_indicators(Menu imenu) {
		for (int i = 0; i < _indicators.size(); ++i) {
			imenu.add(new MenuItem((String) _indicators.elementAt(i)));
		}
		//!!Note: When you get there, the listener(s) that is used to
		//process events for the above menu items can probably use the
		//menu item name, which will be the indicator name, as a key
		//in a hash table that will give the "indicator ID".  The menu
		//item name (I think) will be available from the getActionCommand
		//method of the ActionEvent argument to ActionListener's
		//actionPerformed method.  This will probably be set here.
	}

	/** Close a window.  If this is the last open window, just quit. */
	void close()
	{
		if (--num_windows == 0) System.exit(0);
		else this.dispose();
	}

	private TA_Connection connection;

	// # of open windows - so program can exit when last one is closed
	protected static int num_windows = 0;

	// Main window pane
	TA_ScrollPane main_pane;

	// Valid trading period types - static for now, since it is currently
	// hard-coded in the server
	protected static Vector _period_types;	// Vector of String

	protected static Vector _markets;		// Vector of String

	// Cached list of market indicators
	protected static Vector _indicators;	// Vector of String

	MarketSelection market_selection;
}
