import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.*;
import java.util.*;
import java.io.*;

// Listener that allows user to select a stock to be displayed.
class StockSelection implements ActionListener {
	public StockSelection(Frame f, TA_Connection conn) {
		connection = conn;
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
			System.out.println(connection.last_market_data());
			//!!!Need to find a way to plug the market data into the graph!!!
		}});
	}

	public void actionPerformed(ActionEvent e) {
		dialog.show();
	}

	private List selection;
	private Dialog dialog;
	private TA_Connection connection;
}
