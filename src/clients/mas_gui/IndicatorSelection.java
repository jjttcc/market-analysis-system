/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.event.*;
import java.awt.*;
import java.util.*;
import support.*;

// Listener that allows user to select an indicator to be displayed.
class IndicatorSelection extends DialogSelection {
	public IndicatorSelection(Chart f) {
		super(f);
		int window_width = f.main_pane.getSize().width / 3 + 14;
		final int Min_window_height = 40, Hfactor = 16;
		Enumeration indicators = chart.ordered_indicators().elements();
		while (indicators.hasMoreElements()) {
			selection_list.add((String) indicators.nextElement());
		}
		indicator_listener = new IndicatorListener(chart);
		selection_list.addActionListener(indicator_listener);

		if (! size_was_set) {
			setSize(window_width, (selection_list.getItemCount() + 1) *
				Hfactor + Min_window_height);
		}
		add_close_listener();
	}

	private IndicatorListener indicator_listener;
	
	protected String title() { return "Indicators"; }
}
