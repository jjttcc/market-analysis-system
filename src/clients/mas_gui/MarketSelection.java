/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.*;
import java.util.*;

// Listener that allows user to select a market to be displayed.
class MarketSelection implements ActionListener {
	public MarketSelection(MA_Chart f) {
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
			main_frame.request_data(selection.getSelectedItem());
		}});
	}

	public void actionPerformed(ActionEvent e) {
		dialog.show();
	}

	String current_market() {
		return selection.getSelectedItem();
	}

	private List selection;
	private Dialog dialog;
	private MA_Chart main_frame;
}
