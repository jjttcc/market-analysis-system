import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.*;
import java.util.*;
import graph.*;
import java.io.*;

// Listener that allows user to select a market to be displayed.
class MarketSelection implements ActionListener {
	public MarketSelection(TA_Chart f, TA_Connection conn, Graph2D g) {
		connection = conn;
		graph = g;
		main_frame = f;
		selection = new List();
		dialog = new Dialog(f);
		dialog.add(selection);
		dialog.setSize(140, 300);
		Vector ml = main_frame.markets();
		for (int i = 0; i < ml.size(); ++i) {
			selection.add((String) ml.elementAt(i));
		}
		// Add action listener (anonymous class) to respond to
		// stock selection from list.
		selection.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			dialog.setVisible(false);
			String item = selection.getSelectedItem();
			System.out.println("Retrieving data for " + item);
			try {
				connection.send_market_data_request(item,
					main_frame.current_period_type());
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
	private TA_Chart main_frame;
}
