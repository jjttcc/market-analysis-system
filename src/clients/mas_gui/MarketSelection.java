import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.*;
import java.util.*;
import java.io.*;
import graph.*;

// Listener that allows user to select a market to be displayed.
class MarketSelection implements ActionListener {
	public MarketSelection(Frame f, TA_Connection conn, Graph2D g) {
		connection = conn;
		graph = g;
		main_frame = f;
		selection = new List();
		dialog = new Dialog(f);
		dialog.add(selection);
		dialog.setSize(140, 300);
		try {
			Vector ml = connection.market_list();
			for (int i = 0; i < ml.size(); ++i) {
				selection.add((String) ml.elementAt(i));
			}
		}
		catch (IOException e) {
			System.out.println("IO exception occurred, bye ...");
			System.exit(-1);
		}
		// Add action listener (anonymous class) to respond to
		// stock selection from list.
		selection.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			dialog.setVisible(false);
			String item = selection.getSelectedItem();
			System.out.println("Retrieving data for " + item);
			try {
			//!!!Stubness - hardcoded period type:
			connection.send_market_data_request(item, "daily");
			}
			catch (IOException e2) {
				System.out.println("IO exception occurred, bye ...");
				System.exit(-1);
			}
			//Ensure that all graph's data sets are removed.  (May need to
			//change later.)
			graph.detachDataSets();
			graph.attachDataSet(connection.last_market_data());
			main_frame.setTitle(item);
			graph.repaint();
		}});
	}

	public void actionPerformed(ActionEvent e) {
		dialog.show();
	}

	private List selection;
	private Dialog dialog;
	private TA_Connection connection;
	private Graph2D graph;
	private Frame main_frame;
}
