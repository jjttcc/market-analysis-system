/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.event.*;
import java.awt.*;
import java.util.*;
import support.*;

// Listener that allows user to select a market to be displayed.
class MarketSelection extends DialogSelection {
	public MarketSelection(Chart f) {
		super(f);
		int window_width = f.main_pane.getSize().width / 10 - 4;
		if (! size_was_set) {
			setSize(window_width, 373);
		}
		Vector ml = chart.markets();
		for (int i = 0; i < ml.size(); ++i) {
			selection_list.add((String) ml.elementAt(i));
		}
		// Add action listener (anonymous class) to respond to
		// stock selection from list.
		selection_list.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				chart.request_data(selection_list.getSelectedItem());
		}});
		add_close_listener();
	}

	public String current_market() {
		return selection_list.getSelectedItem();
	}

	protected String title() { return "Symbols"; }
}
