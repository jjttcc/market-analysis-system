// The windowing and event registration code in this class is adapted from
// "Java in a Nutshell, Second Edition", by David Flanagan.  [Copyright (c)
// 1997 O'Reilly & Associates.]  The license for that code says:
// "You may distribute this source code for non-commercial purposes only.
// You may study, modify, and use this example for any purpose, as long as
// this notice is retained.  Note that this example is provided "as is",
// WITHOUT WARRANTY of any kind either expressed or implied."

import java.awt.*;               // ScrollPane, PopupMenu, MenuShortcut, etc.
import java.awt.event.*;         // New event model.

public class TA_Chart extends Frame
{
	public TA_Chart(TA_Connection conn)
	{

		super("TA_Chart");		// Create the main window frame.
		connection = conn;
		num_windows++;			// Count it.

		// Create the main scroll pane, size it, and center it.
		TA_ScrollPane pane = new TA_ScrollPane();
		pane.setSize(610, 410);
		this.add(pane, "Center");

		// Make a menu bar with a file menu.
		MenuBar menubar = new MenuBar();
		this.setMenuBar(menubar);
		Menu file = new Menu("File");
		menubar.add(file);

		// Create three menu items, with menu shortcuts, and add to the menu.
		MenuItem n, c, q;
		file.add(n = new MenuItem("New Window",
							new MenuShortcut(KeyEvent.VK_N)));
		file.add(c = new MenuItem("Close Window",
							new MenuShortcut(KeyEvent.VK_W)));
		file.addSeparator();                     // Put a separator in the menu
		file.add(q = new MenuItem("Quit", new MenuShortcut(KeyEvent.VK_Q)));

		// Create and register action listener objects for the three menu items.
		n.addActionListener(new ActionListener() {     // Open a new window
		public void actionPerformed(ActionEvent e) { new TA_Chart(connection); }
		});

		c.addActionListener(new ActionListener() {     // Close this window.
		public void actionPerformed(ActionEvent e) { close(); }
		});

		q.addActionListener(new ActionListener() {     // Quit the program.
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

  public void execute()
  {
  }

// Implementation

	/** Close a window.  If this is the last open window, just quit. */
	void close()
	{
		if (--num_windows == 0) System.exit(0);
		else this.dispose();
	}

	private TA_Connection connection;

	// # of open windows - so program can exit when last one is closed
	protected static int num_windows = 0;
}
