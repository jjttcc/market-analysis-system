/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.event.*;
import java.awt.*;
import java.util.*;
import support.*;

// Listener that allows user to select an indicator to be displayed.
class IndicatorSelection extends DialogSelection {
	public IndicatorSelection(Chart f) {
		super(f);
		indicator_listener = new IndicatorListener(chart);
		update_indicators(! size_was_set);
		add_close_listener();
	}

	// Update the indicator selection list with the current indicator
	// list.  If `resize', resize the window appropriately.
	public void update_indicators(boolean resize) {
		Enumeration indicators = chart.ordered_indicators().elements();
		selection_list.removeAll();
		while (indicators.hasMoreElements()) {
			selection_list.add((String) indicators.nextElement());
		}
		selection_list.addActionListener(indicator_listener);

		if (resize) {
			int window_width = chart.main_pane.getSize().width / 3 + 14;
			final int Min_window_height = 40, Hfactor = 16;
			setSize(window_width, (selection_list.getItemCount() + 1) *
				Hfactor + Min_window_height);
		}
	}

	private IndicatorListener indicator_listener;
	
	protected String title() { return "Indicators"; }
}
